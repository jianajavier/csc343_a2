SET search_path TO artistdb;

/*

Report all artists and their nationalities who were born
in the same year as the release of the first album by
Steppenwolf. Your query should return an empty table if
no such artist is found. To extract a year from a timestamp
type, use the Extract function, e.g.: Extract (year from
birthdate)

name          | nationality
------------------------+-------------
Celine Dion            | Canada
Don Henley             | America
Kenny Chesney          | America
Kylie Minogue          | Australia
LL Cool Jay            | America
Lisa Marie Presley     | America
Marc Anthony           | America
Steven Alexander James | British
(8 rows)

*/

CREATE VIEW YearFirstSteppenwolfAlbum AS
  SELECT MIN(year) as year
  FROM Album, Artist
  WHERE Album.artist_id = Artist.artist_id and Artist.name = 'Steppenwolf';

SELECT DISTINCT name, nationality
FROM Artist
WHERE Extract (year from birthdate) = (SELECT year FROM YearFirstSteppenwolfAlbum) and
      Artist.artist_id not in (SELECT artist_id FROM Role WHERE role = 'Band')
ORDER BY name;

DROP VIEW YearFirstSteppenwolfAlbum;
