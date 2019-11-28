class AddAuthorizationToGoogleConfigs < ActiveRecord::Migration[6.0]
  def change
    add_column :google_configs, :authorization, :hstore
  end
end
