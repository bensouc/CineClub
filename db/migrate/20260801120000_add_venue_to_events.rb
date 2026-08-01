class AddVenueToEvents < ActiveRecord::Migration[8.1]
  # Indoor / outdoor screening. Existing events default to indoor — the common
  # case — so the column is non-null with a sensible default and no backfill.
  def change
    add_column :events, :venue, :string, null: false, default: "indoor"
  end
end
