SET search_path TO artistdb;

CREATE VIEW ArtistGenreCounts AS
  SELECT Album.artist_id, role, COUNT (DISTINCT genre_id) as distinctgenre
  FROM Album, Artist, (SELECT artist_id, role FROM Role WHERE role != 'Songwriter') AS NSRole
  WHERE Album.artist_id = Artist.artist_id and Artist.artist_id = NSRole.artist_id
  GROUP BY Album.artist_id, role
  HAVING COUNT (DISTINCT genre_id) >= 3

UNION ALL
--CREATE VIEW ArtistSongwriter AS
  SELECT SongGenre.songwriter_id, 'Songwriter' as role, COUNT (DISTINCT genre_id) as distinctsonggenre
  FROM SongGenre, Artist
  WHERE SongGenre.songwriter_id = Artist.artist_id
  GROUP BY SongGenre.songwriter_id
  HAVING COUNT (DISTINCT genre_id) >= 3;

SELECT DISTINCT name, role as capacity, distinctgenre as genres
FROM Artist, ArtistGenreCounts
WHERE Artist.artist_id = ArtistGenreCounts.artist_id and role != 'Songwriter'

UNION ALL

SELECT DISTINCT name, role as capacity, distinctgenre as genres
FROM Artist, ArtistGenreCounts
WHERE Artist.artist_id = ArtistGenreCounts.artist_id and role = 'Songwriter'
ORDER BY genres DESC, name, capacity;

DROP VIEW ArtistGenreCounts;

/*
name      |  capacity  | genres
---------------+------------+--------
Bryan Adams   | Musician   |      3
Kenny Chesney | Songwriter |      3
Steppenwolf   | Band       |      3
(3 rows)

NOT SURE IF THIS ONE IS ACTUALLY RIGHT
*/
