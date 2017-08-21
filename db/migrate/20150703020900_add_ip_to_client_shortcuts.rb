class AddIpToClientShortcuts < ActiveRecord::Migration[5.0]
  def change
    add_column :client_shortcuts, :ip, :string
  end
end
