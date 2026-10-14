CREATE DATABASE evogo_auth OWNER tony;
CREATE DATABASE evogo_users OWNER tony;

\connect tony
CREATE EXTENSION IF NOT EXISTS vector;
