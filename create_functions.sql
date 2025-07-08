-- Register
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

-- Login (normal OR through login provider)
CREATE OR REPLACE FUNCTION login_user(p_email TEXT, p_password TEXT)
RETURNS INTEGER AS $$
DECLARE
    uid INTEGER;
BEGIN
    SELECT user_id INTO uid
    FROM users
    WHERE email = p_email
      AND password = crypt(p_password, password); -- uses hashed comparison

    IF uid IS NULL THEN
        RAISE EXCEPTION 'Invalid credentials';
    END IF;

    RETURN uid;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION login_oauth_user(
    p_provider VARCHAR,
    p_email VARCHAR,
    p_username VARCHAR DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    uid INTEGER;
BEGIN
    -- Try to find existing user
    SELECT user_id INTO uid
    FROM users
    WHERE login_provider = p_provider;

    -- If not found, create a new user
    IF uid IS NULL THEN
        INSERT INTO users (
            username,
            email,
            login_provider
        )
        VALUES (
            COALESCE(p_username, p_email), -- fallback to email as username
            p_email,
            p_provider
        )
        RETURNING user_id INTO uid;
    END IF;

    RETURN uid;
END;
$$ LANGUAGE plpgsql;

-- Update user
CREATE OR REPLACE FUNCTION update_user_profile(
    p_user_id INT,
    p_username VARCHAR DEFAULT NULL,
    p_email VARCHAR DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    UPDATE users
    SET
        username = COALESCE(p_username, username),
        email = COALESCE(p_email, email)
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Delete user
CREATE OR REPLACE FUNCTION delete_user(p_user_id INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM users
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

