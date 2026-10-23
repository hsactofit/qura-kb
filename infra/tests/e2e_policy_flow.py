#!/usr/bin/env python3
"""End-to-end check of the client portal <-> CRM policy flow (stdlib only).

    python3 e2e_policy_flow.py --client http://127.0.0.1:8787 --crm http://127.0.0.1:4000 \
        --crm-email manager@qurainsure.com --crm-password '...' --pdf policy.pdf [--pdf2 other.pdf]

Steps (each prints PASS/FAIL):
  1. a new client signs up on the portal (with mobile)
  2. the CRM links them: account + lead + welcome-call task
  3. the client uploads a policy PDF
  4. the CRM gets it: policy (unverified, source CLIENT_PORTAL) + document + review task
  5. an agent verifies it in the CRM -> the portal shows advisor_verified + a notification
  6. the agent uploads a second policy for the client in the CRM -> it appears on the portal and downloads
  7. the client asks for a renewal quote -> CRM task + renewal opportunity
  8. the agent replies and resolves -> the client sees the reply and the request resolved
  9. the client files a claim with a document -> CRM claim + document; status changes reach the portal

Creates real records (a throwaway client "e2e-<timestamp>@example.com"). Run against a test or
production stack; it never deletes anything. Exit code 0 only if every step passed.
"""

from __future__ import annotations

import argparse
import http.cookiejar
import json
import sys
import time
import uuid
import urllib.error
import urllib.request

RESULTS: list[tuple[str, bool, str]] = []


class Session:
    def __init__(self, base: str, csrf_cookie: str | None = None):
        self.base = base.rstrip("/")
        self.jar = http.cookiejar.CookieJar()
        self.opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(self.jar))
        self.csrf_cookie = csrf_cookie

    def _csrf(self) -> str | None:
        for c in self.jar:
            if c.name == self.csrf_cookie:
                return c.value
        return None

    def call(self, method: str, path: str, body=None, form: dict | None = None, files: dict | None = None, raw=False):
        headers = {}
        data = None
        if files is not None or form is not None:
            boundary = uuid.uuid4().hex
            parts = []
            for k, v in (form or {}).items():
                parts.append(f'--{boundary}\r\nContent-Disposition: form-data; name="{k}"\r\n\r\n{v}\r\n'.encode())
            for k, (name, content, ctype) in (files or {}).items():
                parts.append(
                    f'--{boundary}\r\nContent-Disposition: form-data; name="{k}"; filename="{name}"\r\n'
                    f"Content-Type: {ctype}\r\n\r\n".encode() + content + b"\r\n"
                )
            parts.append(f"--{boundary}--\r\n".encode())
            data = b"".join(parts)
            headers["Content-Type"] = f"multipart/form-data; boundary={boundary}"
        elif body is not None:
            data = json.dumps(body).encode()
            headers["Content-Type"] = "application/json"
        token = self._csrf()
        if token and method != "GET":
            headers["X-CSRF-Token"] = token
        # CRM: production cookies are Secure, so over a plain-http tunnel send the JWT the way
        # the panel's proxy does (Authorization: Bearer).
        for c in self.jar:
            if c.name == "token":
                headers["Authorization"] = f"Bearer {c.value}"
        req = urllib.request.Request(self.base + path, data=data, method=method, headers=headers)
        try:
            with self.opener.open(req, timeout=60) as resp:
                # Production sets Secure cookies; when testing over an http ssh tunnel, still send them.
                for c in self.jar:
                    c.secure = False
                payload = resp.read()
                return resp.status, (payload if raw else json.loads(payload or b"null"))
        except urllib.error.HTTPError as err:
            payload = err.read()
            try:
                return err.code, json.loads(payload)
            except ValueError:
                return err.code, payload.decode(errors="replace")[:300]


def check(name: str, ok: bool, detail: str = "") -> bool:
    RESULTS.append((name, ok, detail))
    print(f"{'PASS' if ok else 'FAIL'}  {name}{f'  ({detail})' if detail else ''}", flush=True)
    return ok


def wait_for(fn, timeout: float, what: str):
    deadline = time.time() + timeout
    while time.time() < deadline:
        value = fn()
        if value:
            return value
        time.sleep(2)
    print(f"      timed out waiting for {what}")
    return None


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--client", required=True, help="client-server base URL (…/api/client is appended)")
    ap.add_argument("--crm", required=True, help="crm-server base URL (…/api/v1 is appended)")
    ap.add_argument("--crm-email", required=True)
    ap.add_argument("--crm-password", required=True)
    ap.add_argument("--pdf", required=True, help="policy PDF the client uploads")
    ap.add_argument("--pdf2", help="policy PDF the agent uploads (defaults to --pdf)")
    ap.add_argument("--sync-timeout", type=float, default=60)
    a = ap.parse_args()

    stamp = time.strftime("%Y%m%d%H%M%S")
    email = f"e2e-{stamp}@example.com"
    mobile = f"9{int(time.time()) % 10**9:09d}"
    client = Session(a.client + "/api/client", csrf_cookie="qura_client_csrf")
    crm = Session(a.crm + "/api/v1")
    pdf = open(a.pdf, "rb").read()
    pdf2 = open(a.pdf2 or a.pdf, "rb").read()

    # 1. sign up
    st, body = client.call("POST", "/auth/signup", {"email": email, "password": "E2e-Passw0rd!", "fullName": f"E2E Client {stamp}", "phone": mobile})
    if not check("client signs up", st == 200, f"HTTP {st}"):
        return report()

    # 2. CRM links the client
    st, body = crm.call("POST", "/auth/login", {"email": a.crm_email, "password": a.crm_password})
    if not check("agent logs in to CRM", st == 200, f"HTTP {st}"):
        return report()

    def find_account():
        st, body = crm.call("GET", f"/accounts?search={urllib.request.quote(f'E2E Client {stamp}')}")
        for row in body.get("data", []) if isinstance(body, dict) else []:
            if row.get("clientUserId"):
                return row
        return None

    account = wait_for(find_account, a.sync_timeout, "portal sign-up in CRM")
    if not check("CRM creates account for the portal sign-up", bool(account and account.get("clientUserId"))):
        return report()
    st, detail = crm.call("GET", f"/accounts/{account['id']}")
    acc = detail.get("data", {})
    check("CRM creates lead + welcome-call task", bool(acc.get("leads")) and any("Welcome call" in t["subject"] for t in acc.get("openTasks", [])))

    # 3. client uploads a policy
    st, body = client.call(
        "POST", "/policies/upload",
        form={"policy_type": "health", "insurer_name": "Star Health", "policy_number": f"E2E-H-{stamp}",
              "coverage_amount": "1000000", "premium_amount": "24780", "start_date": "2025-11-15", "end_date": "2026-11-14"},
        files={"document": ("health-policy.pdf", pdf, "application/pdf")},
    )
    ok = st == 200 and body["data"]["policy"]["verification_status"] == "self_reported"
    if not check("client uploads a policy PDF", ok, f"HTTP {st}"):
        return report()
    client_policy_id = body["data"]["policy"]["id"]

    # 4. CRM receives it
    def portal_doc():
        st, body = crm.call("GET", "/documents/pending?source=CLIENT_PORTAL")
        for d in body.get("data", []) if isinstance(body, dict) else []:
            if d.get("account", {}).get("id") == account["id"]:
                return d
        return None

    doc = wait_for(portal_doc, a.sync_timeout, "portal upload in CRM review queue")
    if not check("CRM queues the upload for review (policy + document + extraction)", bool(doc and doc.get("policy") and doc.get("extractions"))):
        return report()
    st, raw = crm.call("GET", f"/documents/{doc['id']}/file", raw=True)
    check("CRM agent can open the client's PDF", st == 200 and raw[:4] == b"%PDF", f"HTTP {st}")

    # 5. agent verifies
    st, body = crm.call("POST", f"/documents/{doc['id']}/verify", {
        "policyNumber": f"E2E-H-{stamp}", "insurerId": "STAR_HEALTH", "categoryId": "HEALTH",
        "startDate": "2025-11-15", "expiryDate": "2026-11-14", "premium": 24780, "sumInsured": 1000000,
        "insuredName": f"E2E Client {stamp}",
        "coverage": {"summary": "Family floater health cover of Rs 10 lakh for 3 members until 14 Nov 2026.", "benefits": ["Cashless at network hospitals"], "exclusions": ["Cosmetic surgery"]},
    })
    check("agent verifies the policy", st == 200, f"HTTP {st} {body if st != 200 else ''}")

    def verified_on_portal():
        st, body = client.call("GET", f"/policies/{client_policy_id}")
        p = body.get("data") if isinstance(body, dict) else None
        return p if p and p.get("verification_status") == "advisor_verified" else None

    p = wait_for(verified_on_portal, a.sync_timeout, "advisor_verified on portal")
    check("portal shows the policy as verified by the advisor", bool(p))
    check("portal gets the advisor's summary", bool(p and "10 lakh" in (p.get("details") or {}).get("summary", "")))

    # 6. agent uploads another policy for the client
    st, body = crm.call("POST", "/documents/upload", form={"accountId": account["id"]}, files={"file": ("motor-policy.pdf", pdf2, "application/pdf")})
    if check("agent uploads a policy for the client in CRM", st == 201, f"HTTP {st} {body if st != 201 else ''}"):
        st, body2 = crm.call("POST", f"/documents/{body['data']['document']['id']}/verify", {
            "policyNumber": f"E2E-M-{stamp}", "insurerId": "ICICI_LOMBARD", "categoryId": "MOTOR",
            "startDate": "2025-12-01", "expiryDate": "2026-11-30", "premium": 18450, "sumInsured": 940000,
            "registrationNumber": "MH02AB1234", "vehicleMake": "Hyundai", "vehicleModel": "Creta",
        })
        check("agent verifies the CRM-uploaded policy", st == 200, f"HTTP {st}")

        def advisor_policy():
            st, body = client.call("GET", "/policies")
            for row in body.get("data", []) if isinstance(body, dict) else []:
                if row.get("policy_number") == f"E2E-M-{stamp}":
                    return row
            return None

        ap_row = wait_for(advisor_policy, a.sync_timeout, "advisor policy on portal")
        check("portal shows the advisor-added policy", bool(ap_row and ap_row.get("policy_source") == "advisor"))
        if ap_row:
            st, raw = client.call("GET", f"/policies/{ap_row['id']}/download", raw=True)
            check("client downloads the advisor-uploaded PDF", st == 200 and raw[:4] == b"%PDF", f"HTTP {st}")

    # 7. client asks for a renewal quote
    st, body = client.call("POST", f"/policies/{client_policy_id}/request", {"type": "renewal", "message": "Please send renewal options with higher cover."})
    if not check("client requests a renewal quote", st == 200, f"HTTP {st}"):
        return report()
    ticket_id = body["data"]["id"]

    def crm_request():
        st, body = crm.call("GET", "/portal/requests")
        for r in body.get("data", []) if isinstance(body, dict) else []:
            if r.get("ticket", {}) and r["ticket"]["id"] == ticket_id:
                return r
        return None

    req = wait_for(crm_request, a.sync_timeout, "request in CRM portal inbox")
    check("CRM gets the request as a task in the portal inbox", bool(req))
    st, opp = crm.call("GET", "/opportunities")
    opps = opp.get("data", []) if isinstance(opp, dict) else []
    check("CRM opens a renewal opportunity", any(o.get("accountId") == account["id"] and o.get("type") == "RENEWAL" for o in opps))

    # 8. agent replies and resolves
    st, body = crm.call("POST", f"/portal/requests/{ticket_id}/reply", {"message": "Sent you 3 renewal options with 15 lakh cover by email.", "resolve": True})
    check("agent replies and resolves in CRM", st == 201, f"HTTP {st}")

    def reply_on_portal():
        st, body = client.call("GET", f"/support/tickets/{ticket_id}/messages")
        msgs = body.get("data", []) if isinstance(body, dict) else []
        return msgs if any(m.get("from_advisor") for m in msgs) else None

    check("client sees the advisor's reply", bool(wait_for(reply_on_portal, a.sync_timeout, "advisor reply on portal")))

    def resolved():
        st, body = client.call("GET", f"/support/tickets/{ticket_id}")
        return isinstance(body, dict) and body.get("data", {}).get("status") == "resolved"

    check("client's request shows resolved", bool(wait_for(resolved, a.sync_timeout, "request resolved")))
    # 9. claims
    st, body = client.call(
        "POST", "/claims",
        form={"policy_id": client_policy_id, "claim_amount": "48500", "submission_date": time.strftime("%Y-%m-%d"),
              "description": "Hospitalised for 3 days with dengue at Fortis Mulund; paid the bill myself."},
        files={"documents": ("hospital-bill.pdf", pdf, "application/pdf")},
    )
    if check("client files a claim with a document", st == 200, f"HTTP {st} {body if st != 200 else ''}"):
        claim_no = body["data"]["claim_number"]
        client_claim_id = body["data"]["id"]

        def crm_claim():
            st, body = crm.call("GET", "/claims")
            for c in body.get("data", []) if isinstance(body, dict) else []:
                if c.get("claimNumber") == claim_no:
                    return c
            return None

        cc = wait_for(crm_claim, a.sync_timeout, "claim in CRM")
        check("CRM receives the claim with its document", bool(cc and cc.get("documents")), f"{len((cc or {}).get('documents') or [])} document(s)")
        if cc:
            st, body = crm.call("PATCH", f"/claims/{cc['id']}/status", {"status": "SUBMITTED_TO_INSURER", "remarks": "Filed with Star Health, ref CLM-889"})
            check("claims desk updates the status", st == 200, f"HTTP {st} {body if st != 200 else ''}")

            def claim_on_portal():
                st, body = client.call("GET", f"/claims/{client_claim_id}")
                c = body.get("data") if isinstance(body, dict) else None
                return c if c and c.get("status") == "in_review" else None

            pc = wait_for(claim_on_portal, a.sync_timeout, "claim status on portal")
            check("client sees the claim status and timeline", bool(pc and any("insurer" in (e.get("note") or "") for e in pc.get("timeline", []))))

    st, body = client.call("GET", "/notifications")
    items = (body.get("data") or {}).get("notifications", []) if st == 200 and isinstance(body, dict) else []
    titles = [n.get("title") for n in items]
    check("client gets notifications (verified, new policy, reply)", {"Policy verified", "Your advisor replied"} <= set(titles), ", ".join(t for t in titles if t))
    st, body = client.call("GET", "/rm/assignment")
    check("client sees their advisor", st == 200 and bool(body.get("data")), json.dumps(body.get("data"))[:120] if isinstance(body, dict) else "")
    return report()


def report() -> int:
    failed = [r for r in RESULTS if not r[1]]
    print(f"\n{len(RESULTS) - len(failed)}/{len(RESULTS)} passed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
