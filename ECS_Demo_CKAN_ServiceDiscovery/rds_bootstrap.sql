CREATE ROLE datastore_ro NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD 'datastore_ro_password';
CREATE DATABASE datastore OWNER ckan ENCODING 'utf-8';