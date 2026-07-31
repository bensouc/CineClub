class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.string :token, null: false
      t.string :label
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.datetime :expires_at
      t.integer :max_uses
      t.integer :uses_count, null: false, default: 0
      t.datetime :revoked_at

      t.timestamps
    end

    add_index :invitations, :token, unique: true
  end
end
