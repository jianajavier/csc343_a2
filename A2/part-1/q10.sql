SET search_path TO artistdb;


CREATE VIEW AlbumThriller AS 
SELECT album_id
FROM Album           
WHERE title='Thriller';

CREATE TABLE SongsFromThriller AS 
SELECT song_id FROM BelongsToAlbum
WHERE album_id IN (SELECT album_id FROM AlbumThriller);

DELETE FROM Collaboration
WHERE song_id in (SELECT song_id FROM SongsFromThriller);

DELETE FROM ProducedBy
WHERE album_id in (SELECT album_id FROM AlbumThriller);


DELETE FROM BelongsToAlbum WHERE album_id IN
(SELECT album_id FROM AlbumThriller);

DELETE FROM Album WHERE album_id IN
(SELECT album_id FROM AlbumThriller);

DELETE FROM Song AS t1 WHERE t1.song_id IN 
(SELECT song_id FROM SongsFromThriller);
		  

DROP VIEW AlbumThriller CASCADE;
DROP TABLE SongsFromThriller;


