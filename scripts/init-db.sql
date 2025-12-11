-- =====================================================
-- Initial Database Setup Script
-- =====================================================
-- This script runs when PostgreSQL container starts

-- Create application user (if not exists)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'app_user') THEN
        CREATE ROLE app_user WITH LOGIN PASSWORD 'app_password';
    END IF;
END
$$;

-- Create schema
CREATE SCHEMA IF NOT EXISTS devops;

-- Grant permissions
GRANT ALL PRIVILEGES ON SCHEMA devops TO app_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA devops TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA devops GRANT ALL ON TABLES TO app_user;

-- Example table for learning
CREATE TABLE IF NOT EXISTS devops.users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Example table for logs
CREATE TABLE IF NOT EXISTS devops.audit_logs (
    id SERIAL PRIMARY KEY,
    action VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INTEGER,
    user_id INTEGER,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON devops.audit_logs(created_at);

-- Insert sample data
INSERT INTO devops.users (email, name) VALUES 
    ('admin@example.com', 'Admin User'),
    ('developer@example.com', 'Dev User')
ON CONFLICT (email) DO NOTHING;

COMMIT;
