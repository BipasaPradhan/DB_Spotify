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
) RETURNS INTEGER AS $$
DECLARE
    uid INTEGER;
    v_email VARCHAR;
BEGIN
    -- Look up existing user by provider + external ID
    SELECT user_id INTO uid
    FROM users
    WHERE login_provider = p_provider
      AND provider_user_id = p_provider_user_id;

    -- If not found, insert new user
    IF uid IS NULL THEN
        -- Generate email for phone login if not provided
        IF p_provider = 'phone' AND p_email IS NULL THEN
            v_email := p_provider_user_id || '@phone.login';
        ELSE
            v_email := p_email;
        END IF;

        INSERT INTO users (
            username,
            email,
            login_provider,
            provider_user_id,
            phone -- assume your users table has this column
        )
        VALUES (
            COALESCE(p_username, v_email),
            v_email,
            p_provider,
            p_provider_user_id,
            CASE WHEN p_provider = 'phone' THEN p_provider_user_id ELSE NULL END
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
CREATE OR REPLACE FUNCTION get_playlist_details(p_playlist_id INT)
RETURNS TABLE (
    playlist_id INT,
    playlist_name VARCHAR,
    cover_url TEXT,
    owner_id INT,
    song_id INT,
    song_title VARCHAR,
    artist_name VARCHAR,
    duration INTERVAL,
    file_url TEXT,
    "position" INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.playlist_id,
        p.title,
        p.cover_url,
        p.user_id,
        s.song_id,
        s.title,
        a.name AS artist_name,
        s.duration,
        s.file_url,
        ps."position"
    FROM playlists p
    JOIN playlist_songs ps ON p.playlist_id = ps.playlist_id
    JOIN songs s ON ps.song_id = s.song_id
    JOIN artists a ON s.artist_id = a.artist_id
    WHERE p.playlist_id = p_playlist_id
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
    p_artist_id INT,
    p_title TEXT,
    p_country TEXT,
    p_city TEXT,
    p_venue TEXT,
    p_date DATE,
    p_time TIME,
    p_ticket_url TEXT,
    p_is_cancelled BOOLEAN DEFAULT FALSE
)
    RETURNS INT AS $$
DECLARE
    new_concert_id INT;
BEGIN
    INSERT INTO concerts (
        artist_id, title, country, city,
        venue, date, time, ticket_url, is_cancelled
    )
    VALUES (
               p_artist_id, p_title, p_country, p_city,
               p_venue, p_date, p_time, p_ticket_url, p_is_cancelled
           )
    RETURNING concert_id INTO new_concert_id;

    RETURN new_concert_id;
END;
$$ LANGUAGE plpgsql;

-- Add new playlist
CREATE OR REPLACE FUNCTION add_playlist(
    p_title TEXT,
    p_user_id INT,
    p_is_public BOOLEAN
)
    RETURNS INT AS $$
DECLARE
    new_id INT;
BEGIN
    INSERT INTO playlists (
        title, user_id, is_public, created_at
    )
    VALUES (
               p_title, p_user_id, p_is_public, CURRENT_TIMESTAMP
           )
    RETURNING playlist_id INTO new_id;

    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- New playlist with cover_url
CREATE OR REPLACE FUNCTION add_playlist(
    p_title TEXT,
    p_user_id INT,
    p_is_public BOOLEAN,
    p_cover_url TEXT
)
RETURNS INT AS $$
DECLARE
    new_id INT;
BEGIN
    INSERT INTO playlists (
        title,
        user_id,
        is_public,
        created_at,
        cover_url
    )
    VALUES (
        p_title,
        p_user_id,
        p_is_public,
        CURRENT_TIMESTAMP,
        p_cover_url
    )
    RETURNING playlist_id INTO new_id;

    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- Playlist with description
CREATE OR REPLACE FUNCTION add_playlist(
    p_title TEXT,
    p_user_id INT,
    p_is_public BOOLEAN,
    p_cover_url TEXT,
    p_description TEXT
)
    RETURNS INT AS $$
DECLARE
    new_id INT;
BEGIN
    INSERT INTO playlists (
        title,
        user_id,
        is_public,
        created_at,
        cover_url,
        description
    )
    VALUES (
               p_title,
               p_user_id,
               p_is_public,
               CURRENT_TIMESTAMP,
               p_cover_url,
               p_description
           )
    RETURNING playlist_id INTO new_id;

    RETURN new_id;
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

-- Remove song from playlist
CREATE OR REPLACE FUNCTION remove_song_from_playlist(
    p_playlist_id INT,
    p_song_id INT
)
    RETURNS VOID AS $$
BEGIN
    DELETE FROM playlist_songs
    WHERE playlist_id = p_playlist_id
      AND song_id = p_song_id;
END;
$$ LANGUAGE plpgsql;

-- Edit playlist
CREATE OR REPLACE FUNCTION edit_playlist(
    p_playlist_id INT,
    p_title TEXT DEFAULT NULL,
    p_is_public BOOLEAN DEFAULT NULL,
    p_cover_url TEXT DEFAULT NULL
)
    RETURNS VOID AS $$
BEGIN
    UPDATE playlists
    SET
        title = COALESCE(p_title, title),
        is_public = COALESCE(p_is_public, is_public),
        cover_url = COALESCE(p_cover_url, cover_url)
    WHERE playlist_id = p_playlist_id;
END;
$$ LANGUAGE plpgsql;

-- Soft delete playlist
CREATE OR REPLACE FUNCTION soft_delete_playlist(p_playlist_id INT)
    RETURNS VOID AS $$
BEGIN
    UPDATE playlists
    SET is_deleted = TRUE
    WHERE playlist_id = p_playlist_id;
END;
$$ LANGUAGE plpgsql;

-- Get user playlists
CREATE OR REPLACE FUNCTION get_user_playlists(p_user_id INT)
    RETURNS TABLE (
                      playlist_id INT,
                      title VARCHAR,
                      is_public BOOLEAN,
                      cover_url TEXT,
                      created_at TIMESTAMP
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT
            p.playlist_id,
            p.title,
            p.is_public,
            p.cover_url,
            p.created_at
        FROM playlists p
        WHERE p.user_id = p_user_id
          AND p.is_deleted = FALSE
        ORDER BY p.playlist_id;
END;
$$ LANGUAGE plpgsql;

-- Get album and songs
CREATE OR REPLACE FUNCTION get_album_with_songs(p_album_id INT)
RETURNS TABLE (
    album_id INT,
    album_title VARCHAR,
    release_date DATE,
    artist_name VARCHAR,
    song_id INT,
    song_title VARCHAR,
    duration interval
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.album_id,
        a.title,
        a.release_date,
        ar.name,
        s.song_id,
        s.title,
        s.duration
    FROM albums a
    JOIN artists ar ON a.artist_id = ar.artist_id
    JOIN songs s ON s.album_id = a.album_id
    WHERE a.album_id = p_album_id;
END;
$$ LANGUAGE plpgsql;

-- Get song detail
CREATE OR REPLACE FUNCTION get_song_details(p_song_id INT)
RETURNS TABLE (
    song_id INT,
    title VARCHAR,
    duration INTERVAL,
    artist_name VARCHAR,
    album_title VARCHAR,
    release_date DATE,
    genre_name VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.song_id,
        s.title,
        s.duration,
        ar.name AS artist_name,
        al.title AS album_title,
        al.release_date,
        g.name AS genre_name
    FROM songs s
    JOIN artists ar ON s.artist_id = ar.artist_id
    JOIN albums al ON s.album_id = al.album_id
    JOIN genres g ON s.genre_id = g.genre_id
    WHERE s.song_id = p_song_id;
END;
$$ LANGUAGE plpgsql;

-- Set user account_type (backend)
CREATE OR REPLACE FUNCTION set_user_account_type(
    p_user_id INT,
    p_account_type varchar
)
RETURNS BOOLEAN AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = p_user_id) THEN
        RAISE EXCEPTION 'User ID % does not exist', p_user_id;
    END IF;

    UPDATE users
    SET account_type = p_account_type
    WHERE user_id = p_user_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Get full library + liked albums/playlists not owned by user
CREATE OR REPLACE FUNCTION get_user_library_full(p_user_id INT)
RETURNS TABLE (
    media_type media_target_type,
    id INT,
    title varchar,
    cover_url TEXT,
    owner_id INT,
    is_owned BOOLEAN
) AS $$
BEGIN
    RETURN QUERY

    -- 1. Playlists the user owns
    SELECT
        'playlist'::media_target_type,
        p.playlist_id,
        p.title,
        p.cover_url,
        p.user_id,
        TRUE AS is_owned
    FROM playlists p
    WHERE p.user_id = p_user_id

    UNION

    -- 2. Playlists the user added (but doesn’t own)
    SELECT
        'playlist'::media_target_type,
        p.playlist_id,
        p.title,
        p.cover_url,
        p.user_id,
        FALSE
    FROM adds a
    JOIN playlists p ON a.target_id = p.playlist_id
    WHERE a.user_id = p_user_id
      AND a.target_type = 'playlist'
      AND p.user_id <> p_user_id

    UNION

    -- 4. Albums the user added
    SELECT
        'album'::media_target_type,
        a.album_id,
        a.title,
        a.cover_url,
        a.artist_id,
        FALSE
    FROM adds ad
    JOIN albums a ON ad.target_id = a.album_id
    WHERE ad.user_id = p_user_id
      AND ad.target_type = 'album';
END;
$$ LANGUAGE plpgsql;

-- Get subscriptions
CREATE OR REPLACE FUNCTION get_user_subscription(p_user_id INT)
RETURNS subscription_plan AS $$
DECLARE
    v_plan subscription_plan;
BEGIN
    SELECT plan INTO v_plan
    FROM subscription
    WHERE user_id = p_user_id;

    IF v_plan IS NULL THEN
        RAISE EXCEPTION 'No subscription found for user ID %', p_user_id;
    END IF;

    RETURN v_plan;
END;
$$ LANGUAGE plpgsql;

-- Add new artist 
CREATE OR REPLACE FUNCTION add_artist(
    p_name VARCHAR,
    p_bio TEXT DEFAULT NULL,
    p_image_url TEXT DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    new_artist_id INTEGER;
BEGIN
    INSERT INTO artists (name, bio, image_url)
    VALUES (p_name, p_bio, p_image_url)
    RETURNING artist_id INTO new_artist_id;

    RETURN new_artist_id;
END;
$$ LANGUAGE plpgsql;

-- Get artist's songs ranked by stream count
CREATE OR REPLACE FUNCTION get_songs_by_artist(p_artist_id INT)
RETURNS TABLE (
    song_id INT,
    title varchar,
    stream_count BIGINT,
    duration INTERVAL,
    file_url TEXT,
    album_id INT,
    is_explicit BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.song_id,
        s.title,
        s.stream_count,
        s.duration,
        s.file_url,
        s.album_id,
        s.explicit
    FROM songs s
    WHERE s.artist_id = p_artist_id
    ORDER BY s.stream_count DESC;
END;
$$ LANGUAGE plpgsql;

-- Get all artists
CREATE OR REPLACE FUNCTION get_all_artists()
RETURNS TABLE (
    artist_id INT,
    name varchar,
    bio TEXT,
    image_url TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.artist_id,
        a.name,
        a.bio,
        a.image_url
    FROM artists a
    WHERE a.is_deleted = FALSE
    ORDER BY a.name;
END;
$$ LANGUAGE plpgsql;

-- Filter by artist
CREATE OR REPLACE FUNCTION filter_songs_by_artist(p_artist_id INT)
RETURNS TABLE (
    song_id INT,
    title VARCHAR,
    duration INTERVAL,
    file_url TEXT,
    stream_count BIGINT,
    is_explicit BOOLEAN,
    album_id INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.song_id,
        s.title,
        s.duration,
        s.file_url,
        s.stream_count,
        s.explicit,
        s.album_id
    FROM songs s
    WHERE s.artist_id = p_artist_id
    AND s.is_deleted = FALSE
    ORDER BY s.title;  -- optional: sort alphabetically
END;
$$ LANGUAGE plpgsql;

-- Get all concerts
CREATE OR REPLACE FUNCTION get_all_concerts()
RETURNS TABLE (
    concert_id INT,
    title varchar,
    artist_id INT,
    country varchar,
    city varchar,
    venue varchar,
    date DATE,
    "time" TIME,
    ticket_url TEXT,
    is_cancelled BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.concert_id,
        c.title,
        c.artist_id,
        c.country,
        c.city,
        c.venue,
        c.date,
        c."time",
        c.ticket_url,
        c.is_cancelled
    FROM concerts c
    ORDER BY c.date, c."time";
END;
$$ LANGUAGE plpgsql;

-- update artist
CREATE OR REPLACE FUNCTION update_artist(
    p_artist_id INT,
    p_name VARCHAR DEFAULT NULL,
    p_bio TEXT DEFAULT NULL,
    p_image_url TEXT DEFAULT NULL
)
    RETURNS VOID AS $$
BEGIN
    UPDATE artists
    SET
        name = COALESCE(p_name, name),
        bio = COALESCE(p_bio, bio),
        image_url = COALESCE(p_image_url, image_url)
    WHERE artist_id = p_artist_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_song_for_artist(
    p_artist_id INT,
    p_title VARCHAR,
    p_duration INTERVAL,
    p_file_url TEXT,
    p_explicit BOOLEAN,
    p_genre_id INT DEFAULT NULL,
    p_album_id INT DEFAULT NULL
)
    RETURNS INT AS $$
DECLARE
    valid_genre_id INT := NULL;
    valid_album_id INT := NULL;
BEGIN
    -- Validate genre_id exists
    IF p_genre_id IS NOT NULL AND EXISTS (
        SELECT 1 FROM genres WHERE genre_id = p_genre_id
    ) THEN
        valid_genre_id := p_genre_id;
    END IF;

    -- Validate album_id exists and belongs to artist
    IF p_album_id IS NOT NULL AND EXISTS (
        SELECT 1 FROM albums
        WHERE album_id = p_album_id
          AND artist_id = p_artist_id
    ) THEN
        valid_album_id := p_album_id;
    END IF;

    RETURN add_new_song(
            p_title     => p_title,
            p_artist_id => p_artist_id,
            p_duration  => p_duration,
            p_genre_id  => valid_genre_id,
            p_file_url  => p_file_url,
            p_explicit  => p_explicit,
            p_album_id  => valid_album_id
           );
END;
$$ LANGUAGE plpgsql;

-- Edit a song for a specific artist (only if artist_id matches)
CREATE OR REPLACE FUNCTION edit_song_for_artist(
    p_song_id INT,
    p_artist_id INT,
    p_title VARCHAR DEFAULT NULL,
    p_duration INTERVAL DEFAULT NULL,
    p_genre_id INT DEFAULT NULL,
    p_file_url TEXT DEFAULT NULL,
    p_explicit BOOLEAN DEFAULT NULL,
    p_album_id INT DEFAULT NULL
)
    RETURNS VOID AS $$
BEGIN
    -- Ensure the artist owns the song
    IF NOT EXISTS (
        SELECT 1 FROM songs WHERE song_id = p_song_id AND artist_id = p_artist_id
    ) THEN
        RAISE EXCEPTION 'Permission denied: Artist % does not own Song %', p_artist_id, p_song_id;
    END IF;

    -- Validate genre_id if provided
    IF p_genre_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM genres WHERE genre_id = p_genre_id) THEN
            RAISE EXCEPTION 'Invalid genre_id %', p_genre_id;
        END IF;
    END IF;

    -- Validate album_id if provided (must belong to artist)
    IF p_album_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM albums WHERE album_id = p_album_id AND artist_id = p_artist_id
        ) THEN
            RAISE EXCEPTION 'Invalid album_id % for artist %', p_album_id, p_artist_id;
        END IF;
    END IF;

    -- Now update the song with new values or keep old values if NULL
    UPDATE songs
    SET
        title = COALESCE(p_title, title),
        duration = COALESCE(p_duration, duration),
        genre_id = COALESCE(p_genre_id, genre_id),
        file_url = COALESCE(p_file_url, file_url),
        explicit = COALESCE(p_explicit, explicit),
        album_id = COALESCE(p_album_id, album_id)
    WHERE song_id = p_song_id;
END;
$$ LANGUAGE plpgsql;

-- More for crud
CREATE OR REPLACE FUNCTION soft_delete_song_by_artist(
    p_artist_id INT,
    p_song_id INT
)
RETURNS VOID AS $$
BEGIN
    UPDATE songs
    SET is_deleted = TRUE
    WHERE song_id = p_song_id
      AND artist_id = p_artist_id;

    -- Optionally, you can check if any row was updated
    IF NOT FOUND THEN
        RAISE NOTICE 'No song found for artist_id = %, song_id = %', p_artist_id, p_song_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_albums_by_artist(p_artist_id INT)
RETURNS TABLE (
    album_id INT,
    title varchar,
    release_date DATE,
    cover_url TEXT,
    is_deleted BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.album_id,
        a.title,
        a.release_date,
        a.cover_url,
        a.is_delete
    FROM albums a
    WHERE a.artist_id = p_artist_id
      AND a.is_delete = FALSE
    ORDER BY a.release_date DESC;
END;
$$ LANGUAGE plpgsql;

select * from get_albums_by_artist(5);

CREATE OR REPLACE FUNCTION edit_album(
    p_artist_id INT,
    p_album_id INT,
    p_title TEXT,
    p_release_date DATE,
    p_cover_url TEXT
)
RETURNS VOID AS $$
DECLARE
    owner_id INT;
BEGIN
    -- Check album ownership
    SELECT artist_id INTO owner_id
    FROM albums
    WHERE album_id = p_album_id;

    IF owner_id IS NULL THEN
        RAISE EXCEPTION 'Album with ID % does not exist', p_album_id;
    ELSIF owner_id <> p_artist_id THEN
        RAISE EXCEPTION 'Permission denied: artist % cannot edit album % owned by artist %', p_artist_id, p_album_id, owner_id;
    END IF;

    -- Proceed with update
    UPDATE albums
    SET
        title = COALESCE(p_title, title),
        release_date = COALESCE(p_release_date, release_date),
        cover_url = COALESCE(p_cover_url, cover_url)
    WHERE album_id = p_album_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION soft_delete_album_by_artist(
    p_artist_id INT,
    p_album_id INT
)
RETURNS VOID AS $$
BEGIN
    UPDATE albums
    SET is_delete = TRUE
    WHERE album_id = p_album_id
      AND artist_id = p_artist_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'No album found for artist_id = %, album_id = %', p_artist_id, p_album_id;
    END IF;
END;
$$ LANGUAGE plpgsql;



-- Backend CRUD for playlist
CREATE OR REPLACE FUNCTION add_admin_playlist(
    p_title VARCHAR,
    p_is_public BOOLEAN DEFAULT TRUE
)
RETURNS INT AS $$
DECLARE
    new_playlist_id INT;
BEGIN
    INSERT INTO playlists (
        title,
        is_public,
        created_by,
        user_id
    )
    VALUES (
        p_title,
        p_is_public,
        'admin',
            0
    )
    RETURNING playlist_id INTO new_playlist_id;

    RETURN new_playlist_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_song_to_playlist_admin(
    p_playlist_id INT,
    p_song_id INT,
    p_position INT DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
    next_pos INT;
    exists_record BOOLEAN;
BEGIN
    -- Check for existing song in playlist
    SELECT EXISTS (
        SELECT 1 FROM playlist_songs
        WHERE playlist_id = p_playlist_id AND song_id = p_song_id
    ) INTO exists_record;

    IF exists_record THEN
        RAISE NOTICE 'Song already exists in playlist.';
        RETURN;
    END IF;

    -- Determine position if not provided
    IF p_position IS NULL THEN
        SELECT COALESCE(MAX(position), 0) + 1
        INTO next_pos
        FROM playlist_songs
        WHERE playlist_id = p_playlist_id;
    ELSE
        next_pos := p_position;
    END IF;

    -- Insert song
    INSERT INTO playlist_songs (playlist_id, song_id, position)
    VALUES (p_playlist_id, p_song_id, next_pos);
END;
$$ LANGUAGE plpgsql;

-- Delete
CREATE OR REPLACE FUNCTION soft_delete_admin_playlist(
    p_playlist_id INT
)
RETURNS VOID AS $$
DECLARE
    creator_type VARCHAR;
BEGIN
    -- Check who created the playlist
    SELECT created_by INTO creator_type
    FROM playlists
    WHERE playlist_id = p_playlist_id;

    -- Only allow if created by admin
    IF creator_type != 'admin' THEN
        RAISE EXCEPTION 'Only admin playlists can be soft-deleted using this function.';
    END IF;

    -- Soft delete
    UPDATE playlists
    SET is_deleted = TRUE
    WHERE playlist_id = p_playlist_id;
END;
$$ LANGUAGE plpgsql;

-- Get artist details
CREATE OR REPLACE FUNCTION get_artist_details(p_artist_id INT)
    RETURNS TABLE (
                      artist_id     INT,
                      name          VARCHAR,
                      bio           TEXT,
                      image_url     TEXT
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT
            a.artist_id,
            a.name,
            a.bio,
            a.image_url
        FROM artists a
        WHERE a.artist_id = p_artist_id;
END;
$$ LANGUAGE plpgsql;
