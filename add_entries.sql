-- Script for inserting artist

SELECT add_artist(
    'Taylor Swift',
    'American singer-songwriter known for narrative songwriting.',
    'https://fakecdn.com/artist/taylor_swift.jpg?token=fake123abc&expires=1725470000'
);

SELECT add_artist(
    'Drake',
    'Canadian rapper, singer, and songwriter.',
    'https://fakecdn.com/artist/drake.jpg?token=fake456def&expires=1725470000'
);

SELECT add_artist(
    'BTS',
    'South Korean boy band with a global fanbase.',
    'https://fakecdn.com/artist/bts.jpg?token=fake789ghi&expires=1725470000'
);

SELECT add_artist(
    'Billie Eilish',
    'American singer known for her distinctive style.',
    'https://fakecdn.com/artist/billie_eilish.jpg?token=fake101jkl&expires=1725470000'
);

SELECT add_artist(
    'The Weeknd',
    'Canadian artist blending R&B and pop.',
    'https://fakecdn.com/artist/the_weeknd.jpg?token=fake202mno&expires=1725470000'
);

SELECT add_artist(
    'Ariana Grande',
    'Pop and R&B singer known for her vocal range.',
    'https://fakecdn.com/artist/ariana_grande.jpg?token=fake303pqr&expires=1725470000'
);

SELECT add_artist(
    'Ed Sheeran',
    'English singer-songwriter with global hits.',
    'https://fakecdn.com/artist/ed_sheeran.jpg?token=fake404stu&expires=1725470000'
);

SELECT add_artist(
    'Dua Lipa',
    'British pop singer and fashion icon.',
    'https://fakecdn.com/artist/dua_lipa.jpg?token=fake505vwx&expires=1725470000'
);

SELECT add_artist(
    'Bad Bunny',
    'Puerto Rican artist known for Latin trap and reggaeton.',
    'https://fakecdn.com/artist/bad_bunny.jpg?token=fake606yz0&expires=1725470000'
);

SELECT add_artist(
    'Olivia Rodrigo',
    'American pop-rock artist and actress.',
    'https://fakecdn.com/artist/olivia_rodrigo.jpg?token=fake707abc&expires=1725470000'
);


-- Script for genre

INSERT INTO genres (genre_id, name) VALUES
    (1, 'Pop'),
    (2, 'Hip Hop'),
    (3, 'R&B'),
    (4, 'K-Pop'),
    (5, 'Latin'),
    (6, 'Rock'),
    (7, 'Electronic'),
    (8, 'Jazz'),
    (9, 'Classical'),
    (10, 'Afrobeats');

-- Script for album

SELECT add_album('Midnights', 2, '2022-10-21', 'https://fakecdn.com/album/midnights.jpg?token=alb1&expires=1725480000');
SELECT add_album('Certified Lover Boy', 3, '2021-09-03', 'https://fakecdn.com/album/clb.jpg?token=alb2&expires=1725480000');
SELECT add_album('Map of the Soul: 7', 4, '2020-02-21', 'https://fakecdn.com/album/mots7.jpg?token=alb3&expires=1725480000');
SELECT add_album('Happier Than Ever', 5, '2021-07-30', 'https://fakecdn.com/album/happier.jpg?token=alb4&expires=1725480000');
SELECT add_album('After Hours', 6, '2020-03-20', 'https://fakecdn.com/album/after_hours.jpg?token=alb5&expires=1725480000');
SELECT add_album('Positions', 7, '2020-10-30', 'https://fakecdn.com/album/positions.jpg?token=alb6&expires=1725480000');
SELECT add_album('=', 8, '2021-10-29', 'https://fakecdn.com/album/equals.jpg?token=alb7&expires=1725480000');
SELECT add_album('Future Nostalgia', 9, '2020-03-27', 'https://fakecdn.com/album/future_nostalgia.jpg?token=alb8&expires=1725480000');
SELECT add_album('YHLQMDLG', 10, '2020-02-29', 'https://fakecdn.com/album/yhlqmdlg.jpg?token=alb9&expires=1725480000');
SELECT add_album('SOUR', 11, '2021-05-21', 'https://fakecdn.com/album/sour.jpg?token=alb10&expires=1725480000');


-- Filling in the rest of the table (concert)

SELECT add_concert(2, 'Live in Tokyo', 'Japan', 'Tokyo', 'Tokyo Dome', '2025-08-10', '19:00', 'https://tickets.com/tokyo', FALSE);
SELECT add_concert(3, 'Acoustic Night', 'USA', 'New York', 'Madison Square Garden', '2025-09-05', '20:30', 'https://tickets.com/nyc', FALSE);
SELECT add_concert(4, 'Cancelled Tour', 'UK', 'London', 'O2 Arena', '2025-07-20', '18:00', 'https://tickets.com/london', TRUE);
SELECT add_concert(5, 'Eyelashes', 'UK', 'Bristol', 'Bristol Venue', '2025-10-24', '19:00', 'https://tickets.com/bristol', FALSE);
SELECT add_concert(6, 'My Weekend', 'Thailand', 'Bangkok', 'Siam Stadium', '2025-09-30', '19:30', 'https://tickets.com/bangkok', TRUE);
SELECT add_concert(7, 'Grand Opening', 'Italy', 'Rome', 'Piza Tower', '2025-11-24', '21:00', 'https://tickets.com/rome', FALSE);
SELECT add_concert(8, 'Your Shape', 'Philippines', 'Manila', 'National Stadium', '2025-10-31', '20:00', 'https://tickets.com/manila', FALSE);
SELECT add_concert(9, 'Duolingo', 'USA', 'Austin', 'Austin Texas Stadium', '2026-01-02', '20:30', 'https://tickets.com/austin', TRUE);
SELECT add_concert(10, 'Lola Bunny', 'China', 'Shanghai', 'Shanghai Dome', '2025-11-11', '19:30', 'https://ccp.com/shanghai', FALSE);
SELECT add_concert(11, 'Olive Garden', 'Greece', 'Athens', 'Athena Colosseum', '2025-08-08', '18:30', 'https://tickets.com/athens', FALSE);


SELECT add_new_song('Single Track', 5, '00:03:20', 2, 'url.mp3', false);
DO $$
BEGIN

    -- Album 2 songs
    PERFORM add_new_song('Girls Want Girls', 2, '00:03:41', 2, 'https://cdn.com/gwg.mp3', TRUE, 2);
    PERFORM add_new_song('Champagne Poetry', 2, '00:05:36', 2, 'https://cdn.com/champagnepoetry.mp3', FALSE, 2);

    -- Album 3 songs
    PERFORM add_new_song('Black Swan', 3, '00:03:18', 3, 'https://cdn.com/blackswan.mp3', FALSE, 3);
    PERFORM add_new_song('ON', 3, '00:04:06', 3, 'https://cdn.com/on.mp3', FALSE, 3);

    -- Album 4 songs
    PERFORM add_new_song('Getting Older', 4, '00:04:05', 1, 'https://cdn.com/yourpower.mp3', FALSE, 5);
    PERFORM add_new_song("I Didn't Change My Number", 4, '00:04:58', 1, 'https://cdn.com/happierthanever.mp3', TRUE, 5);
    PERFORM add_new_song("Billie Bossa Nova", 4, '00:04:58', 1, 'https://cdn.com/bossa.mp3', FALSE, 5);
    PERFORM add_new_song("my future", 4, '00:04:58', 1, 'https://cdn.com/future.mp3', FALSE, 5);


    -- Album 5 songs
    PERFORM add_new_song('Blinding Lights', 5, '00:03:20', 3, 'https://cdn.com/blindinglights.mp3', FALSE, 6);
    PERFORM add_new_song('Heartless', 5, '00:03:18', 3, 'https://cdn.com/heartless.mp3', TRUE, 6);

    -- Album 6 songs
    PERFORM add_new_song('Positions', 6, '00:02:52', 1, 'https://cdn.com/positions.mp3', FALSE, 4);
    PERFORM add_new_song('34+35', 6, '00:02:54', 1, 'https://cdn.com/34plus35.mp3', TRUE, 4);

    -- Album 7 songs
    PERFORM add_new_song('Shivers', 7, '00:03:27', 1, 'https://cdn.com/shivers.mp3', FALSE, 7);
    PERFORM add_new_song('Bad Habits', 7, '00:03:50', 1, 'https://cdn.com/badhabits.mp3', FALSE, 7);

    -- Album 8 songs
    PERFORM add_new_song('Levitating', 8, '00:03:23', 1, 'https://cdn.com/levitating.mp3', FALSE, 8);
    PERFORM add_new_song('Physical', 8, '00:03:13', 1, 'https://cdn.com/physical.mp3', FALSE, 8);

    -- Album 9 songs
    PERFORM add_new_song('Yo Perreo Sola', 9, '00:02:51', 5, 'https://cdn.com/yoperreo.mp3', TRUE, 9);
    PERFORM add_new_song('La Difícil', 9, '00:03:22', 5, 'https://cdn.com/ladificil.mp3', TRUE, 9);

    -- Album 10 songs
    PERFORM add_new_song('drivers license', 10, '00:04:02', 1, 'https://cdn.com/driverslicense.mp3', FALSE, 10);
    PERFORM add_new_song('good 4 u', 10, '00:02:58', 1, 'https://cdn.com/good4u.mp3', TRUE, 10);

    -- Some singles without albums
    PERFORM add_new_song('Single Track 2', 7, '00:03:10', 1, 'https://cdn.com/singletrack2.mp3', FALSE, NULL);
    PERFORM add_new_song('Single Track 3', 8, '00:03:05', 2, 'https://cdn.com/singletrack3.mp3', TRUE, NULL);

END;
$$ LANGUAGE plpgsql;

INSERT INTO song_stream_counts (song_id, stream_count) VALUES
    (1, 800000000),
    (2, 720000000),
    (3, 500000000),
    (4, 450000000),
    (5, 600000000),
    (6, 550000000),
    (7, 300000000),
    (8, 250000000),
    (9, 1600000000),
    (10, 1000000000),
    (11, 900000000),
    (12, 850000000),
    (13, 700000000),
    (14, 690000000),
    (15, 750000000),
    (16, 500000000),
    (17, 900000000),
    (18, 870000000),
    (19, 1000000000),
    (20, 950000000);

INSERT INTO playlists (playlist_id, title, user_id, is_public, created_at) VALUES
    (1, 'Chill Pop', 5, TRUE, CURRENT_TIMESTAMP),
    (2, 'Hype Hip-Hop', 6, TRUE, CURRENT_TIMESTAMP),
    (3, 'K-Pop Collection', 8, FALSE, CURRENT_TIMESTAMP);

-- Playlist 1: Chill Pop
SELECT add_song_to_playlist(3, 34, 1);
SELECT add_song_to_playlist(3, 35, 2);
SELECT add_song_to_playlist(3, 36, 3);
SELECT add_song_to_playlist(3, 37, 4);
SELECT add_song_to_playlist(3, 38, 5);

-- Playlist 2: Hype Hip-Hop
SELECT add_song_to_playlist(4, 39, 1);
SELECT add_song_to_playlist(4, 40, 2);
SELECT add_song_to_playlist(4, 41, 3);
SELECT add_song_to_playlist(4, 42, 4);
SELECT add_song_to_playlist(4, 43, 5);

-- Playlist 3: K-Pop Collection
SELECT add_song_to_playlist(5, 44, 1);
SELECT add_song_to_playlist(5, 45, 2);
SELECT add_song_to_playlist(5, 46, 3);
SELECT add_song_to_playlist(5, 47, 4);
SELECT add_song_to_playlist(5, 48, 5);


-- Add media like
INSERT INTO adds (user_id, target_type, target_id) VALUES
    (5, 'playlist', 1),
    (8, 'playlist', 3),
    (6, 'album', 2);
    (5, 'playlist', 1),
    (8, 'playlist', 3),
    (6, 'album', 2);
select add_media_to_library(10, 7, 'album');
select add_media_to_library(10, 12, 'song');
select add_media_to_library(10, 13, 'song');
select add_media_to_library(11, 4, 'album');
select add_media_to_library(12, 15, 'song');
select add_media_to_library(13, 2, 'playlist');
select add_media_to_library(5, 3, 'song');


-- Adding users by register
select register_user(
       'Peter',
       'peter@something.com',
       'password'
       );

-- Adding users by outside providers
select login_oauth_user(
       'google', -- login provider
       'googleID-123', -- login token (phone number if provider is phone)
       'joey@example.com', -- email
       'Joey' -- username
       );

-- Adding via phone number
select login_oauth_user(
       'phone',
       '0991234567',
       NULL,
       'Nanu' -- Optional (maybe not needed on initial login/change username later)
       )

-- 4th User (Local)
SELECT register_user(
               'Alice',
               'alice@example.com',
               'alicepassword'
       );

-- 5th User (Local)
SELECT register_user(
               'Bob',
               'bob@music.com',
               'bobsecure'
       );

-- 6th User (Local)
SELECT register_user(
               'Chloe',
               'chloe@somewhere.com',
               'chloe123'
       );

-- 7th User (Google)
SELECT login_oauth_user(
               'google',
               'googleID-999',
               'mia@gmail.com',
               'Mia'
       );

-- 8th User (Apple)
SELECT login_oauth_user(
               'apple',
               'appleID-abc',
               'liam@icloud.com',
               'Liam'
       );

-- 9th User (Phone)
SELECT login_oauth_user(
               'phone',
               '0892345678',
               NULL,
               'Max'
       );

-- 10th User (Phone)
SELECT login_oauth_user(
               'phone',
               '0911112233',
               NULL,
               'Nina'
       );

-- Add follows
select add_follow(5, 6, 'user');
select add_follow(8, 3, 'artist');
select add_follow(8, 6, 'user');
select add_follow(5, 4, 'artist');
select add_follow(5, 6, 'artist');
select add_follow(10, 6, 'user');
select add_follow(11, 7, 'user');
select add_follow(12, 8, 'artist');
select add_follow(5, 8, 'artist');
select add_follow(5, 7, 'user');

-- Add subscriptions
select add_user_subscription(5, 'free');
select add_user_subscription(6, 'student');
select add_user_subscription(8, 'family');
select add_user_subscription(9, 'free');
select add_user_subscription(10, 'free');
select add_user_subscription(11, 'family');
select add_user_subscription(12, 'free');
select add_user_subscription(13, 'student');
select add_user_subscription(14, 'family');
select add_user_subscription(15, 'family');



-- Extras/Unordered
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


DO $$
    BEGIN
        PERFORM add_artist('Leven Kali', 'Wow!', '.jpg');
        PERFORM add_artist('Adi Oasis', 'I love bass', 'wow.jpeg');
        Perform add_artist('Christian Kuria', 'Yay', '.jpeg');
        PERFORM add_artist('wave to earth', 'saranghe', '.jpeg');
        PERFORM add_artist('RINI', 'Rnb!', 'rini.jpeg');
    end;
    $$;

CREATE OR REPLACE FUNCTION add_album(
    p_title VARCHAR,
    p_artist_id INT,
    p_release_date DATE DEFAULT NULL,
    p_cover_url TEXT DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    new_album_id INTEGER;
BEGIN
    INSERT INTO albums (title, artist_id, release_date, cover_url)
    VALUES (p_title, p_artist_id, p_release_date, p_cover_url)
    RETURNING album_id INTO new_album_id;

    RETURN new_album_id;
END;
$$ LANGUAGE plpgsql;



DO $$
BEGIN

    -- Album 2 songs
    PERFORM add_new_song('Girls Want Girls', 2, '00:03:41', 2, 'https://cdn.com/gwg.mp3', TRUE, 14);
    PERFORM add_new_song('Champagne Poetry', 2, '00:05:36', 2, 'https://cdn.com/champagnepoetry.mp3', FALSE, 14);

    -- Album 3 songs
    PERFORM add_new_song('Black Swan', 3, '00:03:18', 3, 'https://cdn.com/blackswan.mp3', FALSE, 15);
    PERFORM add_new_song('ON', 3, '00:04:06', 3, 'https://cdn.com/on.mp3', FALSE, 15);

    -- Album 4 songs
    PERFORM add_new_song('Getting Older', 4, '00:04:05', 1, 'https://cdn.com/yourpower.mp3', FALSE, 16);
    PERFORM add_new_song('I Didnt Change My Number', 4, '00:04:58', 1, 'https://cdn.com/happierthanever.mp3', TRUE, 16);
    PERFORM add_new_song('Billie Bossa Nova', 4, '00:04:58', 1, 'https://cdn.com/bossa.mp3', FALSE, 16);
    PERFORM add_new_song('my future', 4, '00:04:58', 1, 'https://cdn.com/future.mp3', FALSE, 16);


    -- Album 5 songs
    PERFORM add_new_song('Blinding Lights', 5, '00:03:20', 3, 'https://cdn.com/blindinglights.mp3', FALSE, 17);
    PERFORM add_new_song('Heartless', 5, '00:03:18', 3, 'https://cdn.com/heartless.mp3', TRUE, 17);

    -- Album 6 songs
    PERFORM add_new_song('Positions', 6, '00:02:52', 1, 'https://cdn.com/positions.mp3', FALSE, 18);
    PERFORM add_new_song('34+35', 6, '00:02:54', 1, 'https://cdn.com/34plus35.mp3', TRUE, 18);

    -- Album 7 songs
    PERFORM add_new_song('Shivers', 7, '00:03:27', 1, 'https://cdn.com/shivers.mp3', FALSE, 19);
    PERFORM add_new_song('Bad Habits', 7, '00:03:50', 1, 'https://cdn.com/badhabits.mp3', FALSE, 19);

    -- Album 8 songs
    PERFORM add_new_song('Levitating', 8, '00:03:23', 1, 'https://cdn.com/levitating.mp3', FALSE, 20);
    PERFORM add_new_song('Physical', 8, '00:03:13', 1, 'https://cdn.com/physical.mp3', FALSE, 20);

    -- Album 9 songs
    PERFORM add_new_song('Yo Perreo Sola', 9, '00:02:51', 5, 'https://cdn.com/yoperreo.mp3', TRUE, 21);
    PERFORM add_new_song('La Difícil', 9, '00:03:22', 5, 'https://cdn.com/ladificil.mp3', TRUE, 21);

    -- Album 10 songs
    PERFORM add_new_song('drivers license', 10, '00:04:02', 1, 'https://cdn.com/driverslicense.mp3', FALSE, 22);
    PERFORM add_new_song('good 4 u', 10, '00:02:58', 1, 'https://cdn.com/good4u.mp3', TRUE, 22);

    -- Some singles without albums
    PERFORM add_new_song('Single Track 2', 7, '00:03:10', 1, 'https://cdn.com/singletrack2.mp3', FALSE, NULL);
    PERFORM add_new_song('Single Track 3', 8, '00:03:05', 2, 'https://cdn.com/singletrack3.mp3', TRUE, NULL);

END;
$$ LANGUAGE plpgsql;

ALTER TABLE songs
ADD COLUMN featured_artist_id INT REFERENCES artists(artist_id);

CREATE OR REPLACE FUNCTION add_new_song(
    p_title VARCHAR,
    p_artist_id INT,
    p_duration INTERVAL,
    p_genre_id INT,
    p_file_url TEXT,
    p_is_explicit BOOLEAN,
    p_album_id INT,
    p_featured_artist_id INT DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    new_song_id INTEGER;
BEGIN
    INSERT INTO songs (
        title,
        artist_id,
        duration,
        genre_id,
        file_url,
        explicit,
        album_id,
        featured_artist_id
    )
    VALUES (
        p_title,
        p_artist_id,
        p_duration,
        p_genre_id,
        p_file_url,
        p_is_explicit,
        p_album_id,
        p_featured_artist_id
    )
    RETURNING song_id INTO new_song_id;

    RETURN new_song_id;
END;
$$ LANGUAGE plpgsql;



