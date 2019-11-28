class RemoveColumnsFromGoogleConfigs < ActiveRecord::Migration[6.0]
  def change
    remove_column :google_configs, :access_token, :string
    remove_column :google_configs, :refresh_token, :string
  end
end
