class CreateClientShortcuts < ActiveRecord::Migration[5.0]
  def change
    create_table :client_shortcuts do |t|
      t.string :client_id

      t.timestamps null: false
    end
  end
end
