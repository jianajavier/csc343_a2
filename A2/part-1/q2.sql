SET search_path TO artistdb;

CREATE VIEW AlbumsWithGuests AS
  SELECT DISTINCT artist1, album_id
  FROM Collaboration, BelongsToAlbum
  WHERE Collaboration.song_id = BelongsToAlbum.song_id;

CREATE VIEW AvgSalesGuests AS
  SELECT artist_id, avg(sales) as guestavg
  FROM Album, AlbumsWithGuests
  WHERE Album.album_id = AlbumsWithGuests.album_id and artist_id = artist1
  GROUP BY artist_id;

CREATE VIEW AvgSalesSolo AS
  SELECT artist_id, avg(sales) as soloavg
  FROM Album
  WHERE album_id not in (SELECT album_id FROM AlbumsWithGuests)
  GROUP BY artist_id;

CREATE VIEW CollabGreater AS
  SELECT s.artist_id, guestavg
  FROM AvgSalesSolo s, AvgSalesGuests g
  WHERE s.artist_id = g.artist_id and
        guestavg > soloavg;

SELECT DISTINCT name, guestavg as avg_collab_sales
FROM Artist, CollabGreater
WHERE CollabGreater.artist_id = Artist.artist_id
ORDER BY name;

DROP VIEW CollabGreater;
DROP VIEW AvgSalesSolo;
DROP VIEW AvgSalesGuests;
DROP VIEW AlbumsWithGuests;
