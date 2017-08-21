class CreateTestNames < ActiveRecord::Migration[5.0]
  def change
    create_table :test_names do |t|
      t.string :name
      t.string :load_dir

      t.timestamps null: false
    end
  end
end
