class CreateSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :sessions do |t|
      t.date :date
      t.string :name

      t.timestamps
    end
  end
end
