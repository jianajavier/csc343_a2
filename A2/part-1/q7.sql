SET search_path TO artistdb;
	CREATE VIEW AllSongsWithYears AS
	SELECT artist_id, year, SongsinAlbums.song_id AS song_id, songwriter_id, SongsinAlbums.title AS song_name 
	FROM Album, (SELECT album_id, Song.song_id AS song_id, songwriter_id, title 
			FROM Song, BelongsToAlbum
			WHERE Song.song_id = BelongsToAlbum.song_id) AS SongsinAlbums
	WHERE Album.album_id = SongsinAlbums.album_id;



CREATE VIEW SongsCovered AS
	SELECT  a1.song_id AS song_id, a1.year AS year1, a2.year AS year2, a1.artist_id AS artist1_id, a2.artist_id AS artist2_id, a1.song_name AS song_name
	FROM AllSongsWithYears a1, AllSongsWithYears a2
	WHERE a1.song_id = a2.song_id and a1.artist_id != a2.artist_id;



SELECT  s1.song_name AS song_name, s1.year1 AS year, getArtistName.name AS name 
FROM SongsCovered s1, (SELECT name, year1
		FROM SongsCovered temp_s, Artist
		WHERE temp_s.artist1_id = Artist.artist_id
		) AS getArtistName
WHERE s1.year1 = getArtistName.year1
ORDER BY 
	s1.song_name ASC,
	s1.year1 ASC,
	getArtistName.name ASC;

DROP VIEW SongsCovered;
DROP VIEW AllSongsWithYears;

