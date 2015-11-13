SET search_path TO artistdb;

CREATE VIEW CanadianArtists AS
  SELECT name, artist_id
  FROM Artist
  WHERE nationality = 'Canada';

-- create scenario with two in one year, it doesnt exist right now

CREATE VIEW FirstAlbum AS
  SELECT album_id, Album.artist_id, title, year
  FROM Album, (SELECT CanadianArtists.artist_id, MIN (year) as first
                FROM CanadianArtists, Album
                WHERE CanadianArtists.artist_id = Album.artist_id
                GROUP BY CanadianArtists.artist_id) as CA
  WHERE year = first and Album.artist_id = CA.artist_id;

CREATE VIEW CanadianIndie AS
  SELECT album_id, artist_id, title, year
  FROM FirstAlbum
  WHERE album_id NOT IN (SELECT album_id FROM ProducedBy);

CREATE VIEW OtherAlbums AS
  SELECT Album.album_id, CanadianIndie.artist_id, Album.title, Album.year
  FROM CanadianIndie, Album
  WHERE CanadianIndie.artist_id = Album.artist_id
  GROUP BY Album.album_id, CanadianIndie.artist_id, Album.year

  EXCEPT

  SELECT * FROM CanadianIndie;

SELECT name as artist_name
FROM Artist, (SELECT artist_id
FROM RecordLabel, (SELECT artist_id, label_id
                    FROM ProducedBy, OtherAlbums
                    WHERE ProducedBy.album_id = OtherAlbums.album_id) AS LIDs
WHERE RecordLabel.label_id = LIDs.label_id and country = 'America'
) AS ProdUSA
WHERE ProdUSA.artist_id = Artist.artist_id;

DROP VIEW OtherAlbums;
DROP VIEW CanadianIndie;
DROP VIEW FirstAlbum;
DROP VIEW CanadianArtists;
