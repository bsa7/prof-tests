class CreateAnswerVariants < ActiveRecord::Migration[5.0]
  def change
    create_table :answer_variants do |t|
      t.string :answer_id
      t.references :question, index: true, foreign_key: true
      t.text :text

      t.timestamps null: false
    end
  end
end
