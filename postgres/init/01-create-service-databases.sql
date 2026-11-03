-- Runs only once: the first time the Postgres volume is created.
-- Local development only. These passwords are never used anywhere else.

-- identity service
CREATE ROLE identity_app WITH LOGIN PASSWORD 'identity_local_only' CREATEDB;
CREATE DATABASE identity OWNER identity_app;
REVOKE ALL ON DATABASE identity FROM PUBLIC;

-- ticketing service (catalog + booking schemas are created later by Prisma)
CREATE ROLE ticketing_app WITH LOGIN PASSWORD 'ticketing_local_only' CREATEDB;
CREATE DATABASE ticketing OWNER ticketing_app;
REVOKE ALL ON DATABASE ticketing FROM PUBLIC;

-- payments service
CREATE ROLE payments_app WITH LOGIN PASSWORD 'payments_local_only' CREATEDB;
CREATE DATABASE payments OWNER payments_app;
REVOKE ALL ON DATABASE payments FROM PUBLIC;