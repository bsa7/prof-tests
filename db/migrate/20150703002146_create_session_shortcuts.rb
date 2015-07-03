class CreateSessionShortcuts < ActiveRecord::Migration
  def change
    create_table :session_shortcuts do |t|
      t.string :session_id

      t.timestamps null: false
    end
  end
end
