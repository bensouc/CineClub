class CreateChoices < ActiveRecord::Migration[6.1]
  def change
    create_table :choices do |t|
      t.references :user, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.references :session, null: false, foreign_key: true
      t.integer :ranking
      t.boolean :selected

      t.timestamps
    end
  end
end
