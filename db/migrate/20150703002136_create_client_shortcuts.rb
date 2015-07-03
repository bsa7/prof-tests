class CreateClientShortcuts < ActiveRecord::Migration
  def change
    create_table :client_shortcuts do |t|
      t.string :client_id

      t.timestamps null: false
    end
  end
end
