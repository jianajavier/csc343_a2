SET search_path TO artistdb;
INSERT INTO WasInBand(artist_id, band_id, start_year, end_year)
	SELECT WasInBand.artist_id AS artist_id, band_id, 2014, 2015
	FROM Artist, WasInBand
	WHERE name='AC/DC' and Artist.artist_id = WasInBand.band_id;
