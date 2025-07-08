-- User related
CREATE OR REPLACE FUNCTION register_user(
    p_username VARCHAR,
    p_email VARCHAR,
    p_password TEXT,
    p_login_provider VARCHAR DEFAULT 'local'
)
RETURNS INTEGER AS $$
DECLARE
    new_user_id INTEGER;
BEGIN
    INSERT INTO users (
        username,
        email,
        password,
        login_provider
    )
    VALUES (
        p_username,
        p_email,
        crypt(p_password, gen_salt('bf')),  -- hash the password
        COALESCE(p_login_provider, 'local')
    )
    RETURNING user_id INTO new_user_id;

    RETURN new_user_id;
END;
$$ LANGUAGE plpgsql;


