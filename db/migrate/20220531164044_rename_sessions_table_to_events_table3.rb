class RenameSessionsTableToEventsTable3 < ActiveRecord::Migration[6.1]
  def change
    rename_column :choices, :session_id, :event_id
  end
end
