class CreateClients < ActiveRecord::Migration[5.0]
  def change
    create_table :clients do |t|
      t.string :client_id
      t.string :nick

      t.timestamps null: false
    end
  end
end
