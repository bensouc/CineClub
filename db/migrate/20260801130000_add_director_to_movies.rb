class AddDirectorToMovies < ActiveRecord::Migration[8.1]
  # Nullable: films added before this migration have no director until they are
  # looked up again, and TMDB occasionally has no director credited either.
  def change
    add_column :movies, :director, :string
  end
end
