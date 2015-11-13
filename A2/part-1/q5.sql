SET search_path TO artistdb;

/*
This gives the right answer assuming that no songwriter means self songwriter (includes NULL)
*/

CREATE VIEW AlbumsAll AS
  SELECT Album.album_id, song_id
  FROM BelongsToAlbum RIGHT JOIN Album ON Album.album_id = BelongsToAlbum.album_id

CREATE VIEW SongAlbums AS
  SELECT AlbumsAll.album_id, songwriter_id, COUNT (AlbumsAll.song_id)
  FROM Song RIGHT JOIN AlbumsAll ON Song.song_id = AlbumsAll.song_id
  GROUP BY AlbumsAll.album_id, songwriter_id
  ORDER BY AlbumsAll.album_id;

CREATE VIEW OneSongwriter AS
  SELECT songwriter_id, SongAlbums.album_id
  FROM SongAlbums, (SELECT album_id
        FROM SongAlbums
        GROUP BY album_id
        HAVING COUNT(songwriter_id) < 2
        ORDER BY album_id) AS OneWriter
  WHERE SongAlbums.album_id = OneWriter.album_id;

CREATE VIEW WriteOwnMusic AS
  SELECT Album.artist_id, Album.title
  FROM Album JOIN OneSongwriter ON Album.album_id = OneSongwriter.album_id
  WHERE Album.artist_id = OneSongwriter.songwriter_id or OneSongwriter.songwriter_id IS NULL;

SELECT DISTINCT name as artist_name, title as album_name
FROM WriteOwnMusic, Artist
WHERE WriteOwnMusic.artist_id = Artist.artist_id
ORDER BY artist_name, album_name;

DROP VIEW WriteOwnMusic;
DROP VIEW OneSongwriter;
DROP VIEW SongAlbums;
DROP VIEW AlbumsAll;
