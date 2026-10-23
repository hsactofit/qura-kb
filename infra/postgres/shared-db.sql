-- One database for the whole product: qura_main, one schema per service.
-- Each service owns (and migrates) only its schema and can only READ the other's,
-- so the client portal and the CRM work on the same data without stepping on each other.
-- Idempotent: applied on first boot (init/02) and on every boot/deploy (scripts/db-setup.sh).
\set ON_ERROR_STOP on
SELECT 'CREATE DATABASE qura_main' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'qura_main')\gexec
REVOKE ALL ON DATABASE qura_main FROM PUBLIC;
GRANT CONNECT, TEMPORARY ON DATABASE qura_main TO qura_client, qura_crm;

\connect qura_main
REVOKE ALL ON SCHEMA public FROM PUBLIC;
-- Extensions need a superuser here; the services' migrations only ask "IF NOT EXISTS".
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
GRANT USAGE ON SCHEMA public TO qura_client, qura_crm;
CREATE SCHEMA IF NOT EXISTS client AUTHORIZATION qura_client;
CREATE SCHEMA IF NOT EXISTS crm AUTHORIZATION qura_crm;
ALTER ROLE qura_client IN DATABASE qura_main SET search_path = client;
ALTER ROLE qura_crm IN DATABASE qura_main SET search_path = crm;

-- Cross-schema reads (each service syncs by reading the other side).
GRANT USAGE ON SCHEMA client TO qura_crm;
GRANT SELECT ON ALL TABLES IN SCHEMA client TO qura_crm;
ALTER DEFAULT PRIVILEGES FOR ROLE qura_client IN SCHEMA client GRANT SELECT ON TABLES TO qura_crm;
GRANT USAGE ON SCHEMA crm TO qura_client;
GRANT SELECT ON ALL TABLES IN SCHEMA crm TO qura_client;
ALTER DEFAULT PRIVILEGES FOR ROLE qura_crm IN SCHEMA crm GRANT SELECT ON TABLES TO qura_client;
