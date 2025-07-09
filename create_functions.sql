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

-- Login (normal)
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

-- Login via provider
CREATE OR REPLACE FUNCTION login_oauth_user(
    p_provider VARCHAR,             -- e.g. 'google', 'facebook', 'phone'
    p_provider_user_id VARCHAR,     -- the unique ID from the provider
    p_email VARCHAR,
    p_username VARCHAR DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    uid INTEGER;
BEGIN
    -- Look up existing user by provider + external ID
    SELECT user_id INTO uid
    FROM users
    WHERE login_provider = p_provider
      AND provider_user_id = p_provider_user_id;

    -- If not found, insert new user
    IF uid IS NULL THEN
        INSERT INTO users (
            username,
            email,
            login_provider,
            provider_user_id
        )
        VALUES (
            COALESCE(p_username, p_email),
            p_email,
            p_provider,
            p_provider_user_id
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

-- Playlist
CREATE OR REPLACE FUNCTION get_songs_from_playlist(
    p_playlist_id INT
)
RETURNS TABLE (
    song_id INT,
    title VARCHAR,
    artist_name VARCHAR,
    duration INTERVAL,
    genre_id INT,
    file_url TEXT,
    explicit BOOLEAN,
    "position" INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.song_id,
        s.title,
        a.name AS artist_name,
        s.duration,
        s.genre_id,
        s.file_url,
        s.explicit,
        ps."position"
    FROM playlist_songs ps
    JOIN songs s ON ps.song_id = s.song_id
    JOIN artists a ON s.artist_id = a.artist_id
    WHERE ps.playlist_id = p_playlist_id
    ORDER BY ps."position";
END;
$$ LANGUAGE plpgsql;

-- Concert --
-- Delete concert
CREATE OR REPLACE FUNCTION cancel_concert(p_concert_id INT)
RETURNS VOID AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM concerts WHERE concert_id = p_concert_id AND is_cancelled = FALSE
    ) THEN
        UPDATE concerts
        SET is_cancelled = TRUE
        WHERE concert_id = p_concert_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- update concert 
CREATE OR REPLACE FUNCTION update_concert(
    p_concert_id INT,
    p_title VARCHAR DEFAULT NULL,
    p_country VARCHAR DEFAULT NULL,
    p_city VARCHAR DEFAULT NULL,
    p_venue VARCHAR DEFAULT NULL,
    p_date DATE DEFAULT NULL,
    p_time TIME DEFAULT NULL,
    p_ticket_url TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    UPDATE concerts
    SET
        title = COALESCE(p_title, title),
        country = COALESCE(p_country, country),
        city = COALESCE(p_city, city),
        venue = COALESCE(p_venue, venue),
        date = COALESCE(p_date, date),
        time = COALESCE(p_time, time),
        ticket_url = COALESCE(p_ticket_url, ticket_url)
    WHERE concert_id = p_concert_id;
END;
$$ LANGUAGE plpgsql;

-- Get songs from playlist
CREATE OR REPLACE FUNCTION get_songs_from_playlist(
    p_playlist_id INT
)
RETURNS TABLE (
    song_id INT,
    title VARCHAR,
    artist_name VARCHAR,
    duration INTERVAL,
    genre_id INT,
    file_url TEXT,
    explicit BOOLEAN,
    "position" INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.song_id,
        s.title,
        a.name AS artist_name,
        s.duration,
        s.genre_id,
        s.file_url,
        s.explicit,
        ps."position"
    FROM playlist_songs ps
    JOIN songs s ON ps.song_id = s.song_id
    JOIN artists a ON s.artist_id = a.artist_id
    WHERE ps.playlist_id = p_playlist_id
    ORDER BY ps."position";
END;
$$ LANGUAGE plpgsql;

-- Add likes
CREATE OR REPLACE FUNCTION add_media_to_library(
    p_user_id INT,
    p_target_id INT,
    p_target_type media_target_type
)
RETURNS VOID AS $$
BEGIN
    -- Prevent duplicates by ignoring if already exists
    INSERT INTO adds (user_id, target_id, target_type)
    VALUES (p_user_id, p_target_id, p_target_type)
    ON CONFLICT DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- Remove likes
CREATE OR REPLACE FUNCTION remove_media_from_library(
    p_user_id INT,
    p_target_id INT,
    p_target_type media_target_type
)
RETURNS VOID AS $$
BEGIN
    DELETE FROM adds
    WHERE user_id = p_user_id
      AND target_id = p_target_id
      AND target_type = p_target_type;
END;
$$ LANGUAGE plpgsql;

-- Follow function
CREATE OR REPLACE FUNCTION add_follow(
    p_follower_id INT,
    p_followed_id UUID,
    p_type follow_type
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO follows (follower_id, followed_id, type)
    VALUES (p_follower_id, p_followed_id, p_type)
    ON CONFLICT DO NOTHING;
END;
$$ LANGUAGE plpgsql;





