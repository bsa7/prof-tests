class CreateRightAnswers < ActiveRecord::Migration[5.0]
  def change
    create_table :right_answers do |t|
      t.string :answer_id
      t.references :question, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
