-- Register
CREATE OR REPLACE FUNCTION register_user(
    p_username VARCHAR,
    p_email VARCHAR,
    p_password TEXT
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
        'local'  -- default provider for local registration
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

-- Add subscription
CREATE OR REPLACE FUNCTION add_user_subscription(
    p_user_id INT,
    p_plan subscription_plan
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO subscription (user_id, plan)
    VALUES (p_user_id, p_plan)
    ON CONFLICT (user_id) DO UPDATE
    SET plan = EXCLUDED.plan,
        start_date = CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- Remove subscription
CREATE OR REPLACE FUNCTION cancel_user_subscription(
    p_user_id INT
)
RETURNS VOID AS $$
BEGIN
    DELETE FROM subscription
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Change subscription
CREATE OR REPLACE FUNCTION change_user_subscription(
    p_user_id INT,
    p_new_plan subscription_plan
)
RETURNS VOID AS $$
BEGIN
    UPDATE subscription
    SET plan = p_new_plan,
        start_date = CURRENT_TIMESTAMP
    WHERE user_id = p_user_id;

    -- Optionally: Raise a notice if no subscription was updated
    IF NOT FOUND THEN
        RAISE NOTICE 'No active subscription found for user %', p_user_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Add new song
CREATE OR REPLACE FUNCTION add_new_song(
    p_title VARCHAR,
    p_artist_id INT,
    p_duration INTERVAL,
    p_genre_id INT,
    p_file_url TEXT,
    p_explicit BOOLEAN,
    p_album_id INT DEFAULT NULL
)
RETURNS INT AS $$
DECLARE
    new_song_id INT;
BEGIN
    INSERT INTO songs (
        title,
        artist_id,
        duration,
        genre_id,
        file_url,
        explicit,
        album_id
    )
    VALUES (
        p_title,
        p_artist_id,
        p_duration,
        p_genre_id,
        p_file_url,
        p_explicit,
        p_album_id
    )
    RETURNING song_id INTO new_song_id;

    RETURN new_song_id;
END;
$$ LANGUAGE plpgsql;

-- Add album
CREATE OR REPLACE FUNCTION add_album(
    p_title VARCHAR,
    p_artist_id INT,
    p_release_date DATE,
    p_cover_url TEXT
)
RETURNS INT AS $$
DECLARE
    new_album_id INT;
BEGIN
    INSERT INTO albums (
        title,
        artist_id,
        release_date,
        cover_url
    )
    VALUES (
        p_title,
        p_artist_id,
        p_release_date,
        p_cover_url
    )
    RETURNING album_id INTO new_album_id;

    RETURN new_album_id;
END;
$$ LANGUAGE plpgsql;

-- Add song to album
CREATE OR REPLACE FUNCTION add_song_to_album(
    p_album_id INT,
    p_song_id INT
)
RETURNS VOID AS $$
BEGIN
    UPDATE songs
    SET album_id = p_album_id
    WHERE song_id = p_song_id;
END;
$$ LANGUAGE plpgsql;

-- Add new genre
CREATE OR REPLACE FUNCTION add_genre(
    p_genre_id INT,
    p_name TEXT
)
    RETURNS INT AS $$
BEGIN
    INSERT INTO genres (genre_id, name)
    VALUES (p_genre_id, p_name);

    RETURN p_genre_id;
END;
$$ LANGUAGE plpgsql;

-- Add new concert
CREATE OR REPLACE FUNCTION add_concert(
    p_concert_id INT,
    p_artist_id INT,
    p_title TEXT,
    p_country TEXT,
    p_city TEXT,
    p_venue TEXT,
    p_date DATE,
    p_time TIME,
    p_ticket_url TEXT,
    p_is_cancelled BOOLEAN
)
    RETURNS INT AS $$
BEGIN
    INSERT INTO concerts (
        concert_id, artist_id, title, country, city,
        venue, date, time, ticket_url, is_cancelled
    )
    VALUES (
               p_concert_id, p_artist_id, p_title, p_country, p_city,
               p_venue, p_date, p_time, p_ticket_url, p_is_cancelled
           );

    RETURN p_concert_id;
END;
$$ LANGUAGE plpgsql;

-- Add new playlist
CREATE OR REPLACE FUNCTION add_playlist(
    p_playlist_id INT,
    p_title TEXT,
    p_user_id INT,
    p_is_public BOOLEAN
)
    RETURNS INT AS $$
BEGIN
    INSERT INTO playlists (
        playlist_id, title, user_id, is_public, created_at
    )
    VALUES (
               p_playlist_id, p_title, p_user_id, p_is_public, CURRENT_TIMESTAMP
           );

    RETURN p_playlist_id;
END;
$$ LANGUAGE plpgsql;

-- Add new song to playlist
CREATE OR REPLACE FUNCTION add_song_to_playlist(
    p_playlist_id INT,
    p_song_id INT,
    p_position INT
)
    RETURNS INT AS $$
BEGIN
    INSERT INTO playlist_songs (playlist_id, song_id, position)
    VALUES (p_playlist_id, p_song_id, p_position);

    RETURN p_position;
END;
$$ LANGUAGE plpgsql;
