class RenameSessionsTableToEventsTable < ActiveRecord::Migration[6.1]
  def change
    rename_table :sessions, :events
  end
end
