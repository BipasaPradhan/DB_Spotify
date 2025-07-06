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
    (5, 'Latin');

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
