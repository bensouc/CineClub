class RenameSessionsTableToEventsTable2 < ActiveRecord::Migration[6.1]
  def change
    rename_table :event, :events
  end
end
