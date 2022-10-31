class AddOverviewToMovie < ActiveRecord::Migration[6.1]
  def change
    add_column :movies, :overview, :string
  end
end
