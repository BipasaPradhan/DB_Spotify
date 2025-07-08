-- Drop tables if exists
DROP TABLE IF EXISTS song_stream_counts CASCADE;
DROP TABLE IF EXISTS subscriptions CASCADE;
DROP TABLE IF EXISTS follows CASCADE;
DROP TABLE IF EXISTS adds CASCADE;
DROP TABLE IF EXISTS playlist_songs CASCADE;
DROP TABLE IF EXISTS playlists CASCADE;
DROP TABLE IF EXISTS songs CASCADE;
DROP TABLE IF EXISTS genres CASCADE;
DROP TABLE IF EXISTS albums CASCADE;
DROP TABLE IF EXISTS artists CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Create types
CREATE TYPE media_target_type AS ENUM ('song', 'album', 'playlist');
CREATE TYPE subscription_plan AS ENUM ('free', 'student', 'family');
CREATE TYPE follow_type AS ENUM ('user', 'artist');

-- Create tables
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255),
    phone_number VARCHAR(20),
    login_provider VARCHAR(50),
    account_type VARCHAR(20) DEFAULT 'standard'
);

CREATE TABLE artists (
    artist_id serial primary key,
    name varchar(50) not null,
    bio text DEFAULT 'No bio',
    image_url text
);

CREATE TABLE albums (
    album_id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    artist_id INTEGER NOT NULL,
    release_date DATE,
    cover_url TEXT,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE
);

CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE songs (
    song_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    artist_id INTEGER NOT NULL,
    album_id INTEGER NOT NULL,
    genre_id INTEGER,
    duration INTERVAL,
    file_url TEXT NOT NULL,
    explicit BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE,
    FOREIGN KEY (album_id) REFERENCES albums(album_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE SET NULL
);

CREATE TABLE playlists (
    playlist_id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    user_id INTEGER NOT NULL,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE playlist_songs (
    playlist_id INTEGER NOT NULL,
    song_id INTEGER NOT NULL,
    position INTEGER,

    PRIMARY KEY (playlist_id, song_id),

    FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE
);

CREATE TABLE adds (
    user_id INTEGER NOT NULL,
    target_id UUID NOT NULL,
    target_type media_target_type NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


CREATE TABLE follows (
    follower_id INTEGER NOT NULL,
    followed_id INTEGER NOT NULL,
    type follow_type NOT NULL,

    FOREIGN KEY (follower_id) REFERENCES users(user_id) ON DELETE CASCADE
);


CREATE TABLE subscriptions (
    sub_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    plan subscription_plan NOT NULL,
    start_date DATE NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE song_stream_counts (
    song_id INTEGER PRIMARY KEY,
    stream_count BIGINT DEFAULT 0,

    FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE
);

CREATE TABLE concerts (
    concert_id      SERIAL PRIMARY KEY,
    artist_id       INTEGER NOT NULL,
    title           VARCHAR,
    country         VARCHAR,
    city		    VARCHAR,
    venue           VARCHAR,
    date            DATE,
    time            TIME,
    ticket_url      TEXT,
    is_cancelled    BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);
