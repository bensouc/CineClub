class Changemovieyeartype < ActiveRecord::Migration[6.1]
  def change
    remove_column :movies, :year
    add_column :movies, :tmdb_id, :integer
    add_column :movies, :year, :date
  end
end
