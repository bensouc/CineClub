class CreateMovies < ActiveRecord::Migration[6.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.string :kind
      t.string :poster_url
      t.string :trailer_url
      t.string :year

      t.timestamps
    end
  end
end
