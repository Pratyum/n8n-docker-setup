-- PostgreSQL initialization script for n8n
-- This file runs automatically when PostgreSQL starts for the first time

-- Create additional schemas if needed
-- CREATE SCHEMA IF NOT EXISTS n8n_workflows;
-- CREATE SCHEMA IF NOT EXISTS n8n_executions;

-- Set up database settings for optimal n8n performance
ALTER SYSTEM SET max_connections = 200;
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET work_mem = '4MB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';

-- Create indexes for better performance (n8n will create the tables)
-- These will be created after n8n initializes the database
-- You can add them manually later if needed

-- Uncomment below if you want to create additional users
-- CREATE USER n8n_readonly WITH PASSWORD 'readonly123';
-- GRANT CONNECT ON DATABASE n8n TO n8n_readonly;
-- GRANT USAGE ON SCHEMA public TO n8n_readonly;
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO n8n_readonly;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO n8n_readonly;

SELECT 'n8n PostgreSQL database initialized successfully!' as message;