BEGIN;

/*  CLEAN DB FROM USERS NOT LONGER IN THE USERS TABLE */
DELETE FROM session_ids WHERE email NOT IN (SELECT email FROM users);
DELETE FROM playlist_videos WHERE plid IN (SELECT id FROM playlists WHERE author NOT IN (SELECT email FROM users));
DELETE FROM playlists WHERE author NOT IN (SELECT email FROM users);

COMMIT;
