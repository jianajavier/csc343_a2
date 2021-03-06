import java.util.ArrayList;
import java.sql.*;
import java.util.Collections;

public class Assignment2 {

	/* A connection to the database */
	private Connection connection;

	/**
	 * Empty constructor. There is no need to modify this.
	 */
	public Assignment2() {
		try {
			Class.forName("org.postgresql.Driver");
		} catch (ClassNotFoundException e) {
			System.err.println("Failed to find the JDBC driver");
		}
	}

	/**
	* Establishes a connection to be used for this session, assigning it to
	* the instance variable 'connection'.
	*
	* @param  url       the url to the database
	* @param  username  the username to connect to the database
	* @param  password  the password to connect to the database
	* @return           true if the connection is successful, false otherwise
	*/
	public boolean connectDB(String url, String username, String password) {
		try {
			this.connection = DriverManager.getConnection(url, username, password);
			return true;
		} catch (SQLException se) {
			System.err.println("SQL Exception. <Message>: " + se.getMessage());
			return false;
		}
	}

	/**
	* Closes the database connection.
	*
	* @return true if the closing was successful, false otherwise
	*/
	public boolean disconnectDB() {
		try {
			this.connection.close();
		return true;
		} catch (SQLException se) {
			System.err.println("SQL Exception. <Message>: " + se.getMessage());
			return false;
		}
	}

	/**
	 * Returns a sorted list of the names of all musicians and bands
	 * who released at least one album in a given genre.
	 *
	 * Returns an empty list if no such genre exists or no artist matches.
	 *
	 * NOTE:
	 *    Use Collections.sort() to sort the names in ascending
	 *    alphabetical order.
	 *
	 * @param genre  the genre to find artists for
	 * @return       a sorted list of artist names
	 */
	public ArrayList<String> findArtistsInGenre(String genre) {

		PreparedStatement pStatement;
		ResultSet rs;
		String queryString;
		ArrayList<String> arrayList = new ArrayList<String>();

		try {
			Statement statement = connection.createStatement();
			statement.execute("SET search_path TO artistdb");


			queryString = "CREATE VIEW GenreMatch AS SELECT Genre.genre_id, genre FROM Genre, Album WHERE Genre.genre_id = Album.genre_id;" +
			"CREATE VIEW ArtistAlbum AS SELECT name, genre_id FROM Artist, Album WHERE Artist.artist_id = Album.artist_id;";

			Statement statement2 = connection.createStatement();
			statement2.executeUpdate(queryString);

			queryString = "SELECT DISTINCT name FROM GenreMatch, ArtistAlbum WHERE ArtistAlbum.genre_id = GenreMatch.genre_id and GenreMatch.genre = \'" + genre + "\';";

			pStatement = connection.prepareStatement(queryString);
			rs = pStatement.executeQuery();

			while (rs.next()) {

				arrayList.add(rs.getString("name"));
		 }
		 Collections.sort(arrayList);

		 queryString = "DROP VIEW GenreMatch;"+
		 "DROP VIEW ArtistAlbum;";

		 statement2 = connection.createStatement();
		 statement2.executeUpdate(queryString);

	 } catch (SQLException se)
	 {
	 System.err.println("SQL Exception." +
					 "<Message>: " + se.getMessage());
	 }

		return arrayList;
	}

	/**
	 * Returns a sorted list of the names of all collaborators
	 * (either as a main artist or guest) for a given artist.
	 *
	 * Returns an empty list if no such artist exists or the artist
	 * has no collaborators.
	 *
	 * NOTE:
	 *    Use Collections.sort() to sort the names in ascending
	 *    alphabetical order.
	 *
	 * @param artist  the name of the artist to find collaborators for
	 * @return        a sorted list of artist names
	 */
	public ArrayList<String> findCollaborators(String artist) {
		PreparedStatement pStatement;
		ResultSet rs;
		String queryString;
		ArrayList<String> arrayList = new ArrayList<String>();

		try {
			Statement statement = connection.createStatement();
			statement.execute("SET search_path TO artistdb");

			queryString = "SELECT name as artist FROM Artist, (select distinct artist2 as artist from Collaboration, Artist where artist1 = artist_id and name = ? UNION select distinct artist1 as artist from Collaboration, Artist where artist2 = artist_id and name = ?) as Collab WHERE Artist.artist_id = Collab.artist;";

			pStatement = connection.prepareStatement(queryString);
			pStatement.setString(1, artist);
			pStatement.setString(2, artist);

			rs = pStatement.executeQuery();

			while (rs.next()) {
				arrayList.add(rs.getString("artist"));
		 }
		 Collections.sort(arrayList);


	 } catch (SQLException se)
	 {
	 System.err.println("SQL Exception." +
					 "<Message>: " + se.getMessage());
	 }

		return arrayList;
	}


	/**
	 * Returns a sorted list of the names of all songwriters
	 * who wrote songs for a given artist (the given artist is excluded).
	 *
	 * Returns an empty list if no such artist exists or the artist
	 * has no other songwriters other than themself.
	 *
	 * NOTE:
	 *    Use Collections.sort() to sort the names in ascending
	 *    alphabetical order.
	 *
	 * @param artist  the name of the artist to find the songwriters for
	 * @return        a sorted list of songwriter names
	 */
	public ArrayList<String> findSongwriters(String artist) {
		PreparedStatement pStatement;
		ResultSet rs;
		String queryString;
		ArrayList<String> arrayList = new ArrayList<String>();

		try {
			Statement statement = connection.createStatement();
			statement.execute("SET search_path TO artistdb");


			queryString = "CREATE VIEW SangByArtist AS SELECT album_id, Artist.artist_id AS artist_id FROM Album, Artist WHERE name =\'" + artist +  "\' and Artist.artist_id=Album.artist_id;" +
				"CREATE VIEW SongsSangByArtist AS SELECT songwriter_id FROM BelongsToAlbum, Song WHERE BelongsToAlbum.song_id = Song.song_id and BelongsToAlbum.album_id IN (SELECT album_id from SangByArtist) and songwriter_id NOT IN (SELECT artist_id FROM SangByArtist)";

			Statement statement2 = connection.createStatement();
			statement2.executeUpdate(queryString);

			queryString = "SELECT DISTINCT name FROM SongsSangByArtist, Artist WHERE songwriter_id = artist_id;";

			pStatement = connection.prepareStatement(queryString);
			rs = pStatement.executeQuery();

			while (rs.next()) {

				arrayList.add(rs.getString("name"));
			}
			Collections.sort(arrayList);

			queryString = "DROP VIEW SongsSangByArtist;" + 
			
			"DROP VIEW SangByArtist;";

			statement2 = connection.createStatement();
			statement2.executeUpdate(queryString);

		} catch (SQLException se)
		{
			System.err.println("SQL Exception." +
					"<Message>: " + se.getMessage());
		}

		return arrayList;
	}

	/**
	 * Returns a sorted list of the names of all acquaintances
	 * for a given pair of artists.
	 *
	 * Returns an empty list if either of the artists does not exist,
	 * or they have no acquaintances.
	 *
	 * NOTE:
	 *    Use Collections.sort() to sort the names in ascending
	 *    alphabetical order.
	 *
	 * @param artist1  the name of the first artist to find acquaintances for
	 * @param artist2  the name of the second artist to find acquaintances for
	 * @return         a sorted list of artist names
	 */
	public ArrayList<String> findAcquaintances(String artist1, String artist2) {
		ArrayList<String> arrayList = new ArrayList<String>();
			ArrayList<String> collaboratersfor1 = findCollaborators(artist1);	
			ArrayList<String> collaboratersfor2 = findCollaborators(artist2);	
			ArrayList<String> writersfor1 = findSongwriters(artist1);
			ArrayList<String> writersfor2 = findSongwriters(artist2);

			ArrayList<String> acquaintances1 = new ArrayList<String>();
			acquaintances1.addAll(collaboratersfor1);	
			acquaintances1.addAll(writersfor1);
			ArrayList<String> acquaintances2 = new ArrayList<String>();
			acquaintances2.addAll(collaboratersfor2);	
			acquaintances2.addAll(writersfor2);

			for (int i = 0; i < acquaintances1.size(); i++){
				for (int j = 0; j < acquaintances2.size(); j++){
					if (acquaintances1.get(i).equals(acquaintances2.get(j))){
						arrayList.add(acquaintances2.get(j));
					}
				}
			}

	   	Collections.sort(arrayList);	

		return arrayList;
	}

	public static void main(String[] args) {

		Assignment2 a2 = new Assignment2();

		/* TODO: Change the database name and username to your own here. */
		a2.connectDB("jdbc:postgresql://localhost:5432/csc343h-c5chenjk",
		             "c5chenjk",
		             "");
                System.err.println("\n----- ArtistsInGenre -----");
                ArrayList<String> res = a2.findArtistsInGenre("Rock");
                for (String s : res) {
                  System.err.println(s);
                }

		System.err.println("\n----- Collaborators -----");
		res = a2.findCollaborators("Michael Jackson");
		for (String s : res) {
		  System.err.println(s);
		}

		System.err.println("\n----- Songwriters -----");
	        res = a2.findSongwriters("Justin Bieber");
		for (String s : res) {
		  System.err.println(s);
		}

		System.err.println("\n----- Acquaintances -----");
		res = a2.findAcquaintances("Jaden Smith", "Miley Cyrus");
		for (String s : res) {
		  System.err.println(s);
		}


		a2.disconnectDB();
	}
}
