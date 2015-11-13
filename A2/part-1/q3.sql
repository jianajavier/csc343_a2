SET search_path TO artistdb;

CREATE VIEW LabelAlbumYear AS
  SELECT label_id, year, sales
  FROM Album, ProducedBy
  WHERE ProducedBy.album_id = Album.album_id
  GROUP BY label_id, year, sales;
  /*ORDER BY label_id, year;*/

SELECT label_name as record_label, year, sum(sales) as total_sales
FROM LabelAlbumYear, RecordLabel
WHERE LabelAlbumYear.label_id = RecordLabel.label_id
GROUP BY label_name, year
ORDER BY label_name, year;

DROP VIEW LabelAlbumYear;
