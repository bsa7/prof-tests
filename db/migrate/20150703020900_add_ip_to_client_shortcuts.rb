class AddIpToClientShortcuts < ActiveRecord::Migration
  def change
    add_column :client_shortcuts, :ip, :string
  end
end
