class CreateSessionShortcuts < ActiveRecord::Migration[5.0]
  def change
    create_table :session_shortcuts do |t|
      t.string :session_id

      t.timestamps null: false
    end
  end
end
