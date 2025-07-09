-- Script for inserting artist

INSERT INTO artists (artist_id, name, bio, image_url) VALUES
    (1, 'Taylor Swift', 'American singer-songwriter known for narrative songwriting.', 'https://fakecdn.com/artist/taylor_swift.jpg?token=fake123abc&expires=1725470000'),
    (2, 'Drake', 'Canadian rapper, singer, and songwriter.', 'https://fakecdn.com/artist/drake.jpg?token=fake456def&expires=1725470000'),
    (3, 'BTS', 'South Korean boy band with a global fanbase.', 'https://fakecdn.com/artist/bts.jpg?token=fake789ghi&expires=1725470000'),
    (4, 'Billie Eilish', 'American singer known for her distinctive style.', 'https://fakecdn.com/artist/billie_eilish.jpg?token=fake101jkl&expires=1725470000'),
    (5, 'The Weeknd', 'Canadian artist blending R&B and pop.', 'https://fakecdn.com/artist/the_weeknd.jpg?token=fake202mno&expires=1725470000'),
    (6, 'Ariana Grande', 'Pop and R&B singer known for her vocal range.', 'https://fakecdn.com/artist/ariana_grande.jpg?token=fake303pqr&expires=1725470000'),
    (7, 'Ed Sheeran', 'English singer-songwriter with global hits.', 'https://fakecdn.com/artist/ed_sheeran.jpg?token=fake404stu&expires=1725470000'),
    (8, 'Dua Lipa', 'British pop singer and fashion icon.', 'https://fakecdn.com/artist/dua_lipa.jpg?token=fake505vwx&expires=1725470000'),
    (9, 'Bad Bunny', 'Puerto Rican artist known for Latin trap and reggaeton.', 'https://fakecdn.com/artist/bad_bunny.jpg?token=fake606yz0&expires=1725470000'),
    (10, 'Olivia Rodrigo', 'American pop-rock artist and actress.', 'https://fakecdn.com/artist/olivia_rodrigo.jpg?token=fake707abc&expires=1725470000');

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

INSERT INTO albums (album_id, artist_id, title, release_date, cover_url) VALUES
    (1, 1, 'Midnights', '2022-10-21', 'https://fakecdn.com/album/midnights.jpg?token=alb1&expires=1725480000'),
    (2, 2, 'Certified Lover Boy', '2021-09-03', 'https://fakecdn.com/album/clb.jpg?token=alb2&expires=1725480000'),
    (3, 3, 'Map of the Soul: 7', '2020-02-21', 'https://fakecdn.com/album/mots7.jpg?token=alb3&expires=1725480000'),
    (4, 4, 'Happier Than Ever', '2021-07-30', 'https://fakecdn.com/album/happier.jpg?token=alb4&expires=1725480000'),
    (5, 5, 'After Hours', '2020-03-20', 'https://fakecdn.com/album/after_hours.jpg?token=alb5&expires=1725480000'),
    (6, 6, 'Positions', '2020-10-30', 'https://fakecdn.com/album/positions.jpg?token=alb6&expires=1725480000'),
    (7, 7, '=', '2021-10-29', 'https://fakecdn.com/album/equals.jpg?token=alb7&expires=1725480000'),
    (8, 8, 'Future Nostalgia', '2020-03-27', 'https://fakecdn.com/album/future_nostalgia.jpg?token=alb8&expires=1725480000'),
    (9, 9, 'YHLQMDLG', '2020-02-29', 'https://fakecdn.com/album/yhlqmdlg.jpg?token=alb9&expires=1725480000'),
    (10, 10, 'SOUR', '2021-05-21', 'https://fakecdn.com/album/sour.jpg?token=alb10&expires=1725480000');

-- Filling in the rest of the table

INSERT INTO concerts (concert_id, artist_id, title, country, city, venue, date, time, ticket_url, is_cancelled) VALUES
    (1, 1, 'Live in Tokyo', 'Japan', 'Tokyo', 'Tokyo Dome', '2025-08-10', '19:00', 'https://tickets.com/tokyo', FALSE),
    (2, 2, 'Acoustic Night', 'USA', 'New York', 'Madison Square Garden', '2025-09-05', '20:30', 'https://tickets.com/nyc', FALSE),
    (3, 3, 'Cancelled Tour', 'UK', 'London', 'O2 Arena', '2025-07-20', '18:00', 'https://tickets.com/london', TRUE),
    (4, 4, 'Eyelashes', 'UK', 'Bristol', 'Bristol Venue', '2025-10-24', '19:00','https://tickets.com/bristol', FALSE),
    (5, 5, 'My Weekend', 'Thailand', 'Bangkok', 'Siam Stadium', '2025-9-30', '19:30', 'https://tickets.com/bangkok', TRUE),
    (6, 6, 'Grand Opening', 'Italy', 'Rome', 'Piza Tower', '2025-11-24', '21:00', 'https://tickets.com/rome', FALSE),
    (7, 7, 'Your Shape', 'Philippines', 'Manila', 'National Stadium', '2025-10-31', '20:00', 'https://tickets.com/manila', FALSE),
    (8, 8, 'Duolingo', 'USA', 'Austin', 'Austin Texas Stadium', '2026-1-2', '20:30', 'https://tickets.com/austin', TRUE),
    (9, 9, 'Lola Bunny', 'China', 'Shanghai', 'Shanghai Dome', '2025-11-11', '19:30', 'https://ccp.com/shanghai', FALSE),
    (10, 10, 'Olive Garden', 'Greece', 'Athens', 'Athena Colosseum', '2025-8-8', '18:30', 'https://tickets.com/athens', FALSE);

INSERT INTO songs (song_id, title, artist_id, album_id, genre_id, duration, file_url, explicit) VALUES
    -- Album 1
    (1, 'Anti-Hero', 1, 1, 1, '00:03:20', 'https://cdn.com/antihero.mp3', FALSE),
    (2, 'Lavender Haze', 1, 1, 1, '00:03:22', 'https://cdn.com/lavenderhaze.mp3', FALSE),

    -- Album 2
    (3, 'Girls Want Girls', 2, 2, 2, '00:03:41', 'https://cdn.com/gwg.mp3', TRUE),
    (4, 'Champagne Poetry', 2, 2, 2, '00:05:36', 'https://cdn.com/champagnepoetry.mp3', FALSE),

    -- Album 3
    (5, 'Black Swan', 3, 3, 3, '00:03:18', 'https://cdn.com/blackswan.mp3', FALSE),
    (6, 'ON', 3, 3, 3, '00:04:06', 'https://cdn.com/on.mp3', FALSE),

    -- Album 4
    (7, 'Your Power', 4, 4, 1, '00:04:05', 'https://cdn.com/yourpower.mp3', FALSE),
    (8, 'Happier Than Ever', 4, 4, 1, '00:04:58', 'https://cdn.com/happierthanever.mp3', FALSE),

    -- Album 5
    (9, 'Blinding Lights', 5, 5, 3, '00:03:20', 'https://cdn.com/blindinglights.mp3', FALSE),
    (10, 'Heartless', 5, 5, 3, '00:03:18', 'https://cdn.com/heartless.mp3', TRUE),

    -- Album 6
    (11, 'Positions', 6, 6, 1, '00:02:52', 'https://cdn.com/positions.mp3', FALSE),
    (12, '34+35', 6, 6, 1, '00:02:54', 'https://cdn.com/34plus35.mp3', TRUE),

    -- Album 7
    (13, 'Shivers', 7, 7, 1, '00:03:27', 'https://cdn.com/shivers.mp3', FALSE),
    (14, 'Bad Habits', 7, 7, 1, '00:03:50', 'https://cdn.com/badhabits.mp3', FALSE),

    -- Album 8
    (15, 'Levitating', 8, 8, 1, '00:03:23', 'https://cdn.com/levitating.mp3', FALSE),
    (16, 'Physical', 8, 8, 1, '00:03:13', 'https://cdn.com/physical.mp3', FALSE),

    -- Album 9
    (17, 'Yo Perreo Sola', 9, 9, 5, '00:02:51', 'https://cdn.com/yoperreo.mp3', TRUE),
    (18, 'La Difícil', 9, 9, 5, '00:03:22', 'https://cdn.com/ladificil.mp3', TRUE),

    -- Album 10
    (19, 'drivers license', 10, 10, 1, '00:04:02', 'https://cdn.com/driverslicense.mp3', FALSE),
    (20, 'good 4 u', 10, 10, 1, '00:02:58', 'https://cdn.com/good4u.mp3', TRUE);

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
INSERT INTO playlist_songs (playlist_id, song_id, position) VALUES
    (1, 1, 1),
    (1, 2, 2),
    (1, 11, 3),
    (1, 15, 4),
    (1, 19, 5);

-- Playlist 2: Hype Hip-Hop
INSERT INTO playlist_songs (playlist_id, song_id, position) VALUES
    (2, 3, 1),
    (2, 4, 2),
    (2, 10, 3),
    (2, 12, 4),
    (2, 20, 5);

-- Playlist 3: K-Pop Collection
INSERT INTO playlist_songs (playlist_id, song_id, position) VALUES
    (3, 5, 1),
    (3, 6, 2),
    (3, 9, 3),
    (3, 16, 4),
    (3, 18, 5);

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