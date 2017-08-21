class CreateClientAnswers < ActiveRecord::Migration[5.0]
  def change
    create_table :client_answers do |t|
      t.string :client_shortcut_id
      t.string :session_shortcut_id
      t.references :question, index: true, foreign_key: true
      t.string :answer_id
      t.boolean :is_right

      t.timestamps null: false
    end
  end
end
