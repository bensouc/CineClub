class AddUniqueIndexOnMoviesTmdbId < ActiveRecord::Migration[8.1]
  def up
    # Movie.find_or_create_from_tmdb looks a movie up by tmdb_id before calling
    # TMDB, so duplicates would silently split a film's votes across two rows.
    # Collapse any that already exist onto the oldest row before enforcing it.
    execute <<~SQL
      UPDATE choices
      SET movie_id = keepers.keeper_id
      FROM (
        SELECT id AS duplicate_id,
               FIRST_VALUE(id) OVER (PARTITION BY tmdb_id ORDER BY id) AS keeper_id
        FROM movies
        WHERE tmdb_id IS NOT NULL
      ) AS keepers
      WHERE choices.movie_id = keepers.duplicate_id
        AND keepers.duplicate_id <> keepers.keeper_id
    SQL

    execute <<~SQL
      DELETE FROM movies
      WHERE tmdb_id IS NOT NULL
        AND id NOT IN (SELECT MIN(id) FROM movies WHERE tmdb_id IS NOT NULL GROUP BY tmdb_id)
    SQL

    add_index :movies, :tmdb_id, unique: true
  end

  def down
    remove_index :movies, :tmdb_id
  end
end
