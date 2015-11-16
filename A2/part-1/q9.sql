SET search_path TO artistdb;

UPDATE WasInBand
SET end_year='2014'
FROM (SELECT a2.artist_id
	FROM Artist a2
	WHERE name='Adam Levine') AS sub
WHERE WasInBand.artist_id=sub.artist_id;

UPDATE WasInBand
SET end_year='2014'
FROM (SELECT a2.artist_id
	FROM Artist a2
	WHERE name='Mick Jagger') AS sub
WHERE WasInBand.artist_id=sub.artist_id;

INSERT INTO WasInBand(artist_id, band_id, start_year, end_year)
	SELECT a1.artist_id AS artist_id, sub.artist_id AS band_id, 2014, 2015
	FROM Artist a1, (SELECT a2.artist_id
			FROM Artist a2
			WHERE name='Maroon 5') sub
	WHERE a1.name='Mick Jagger';


