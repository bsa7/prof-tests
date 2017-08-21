class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.text :text
      t.references :test_name, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
