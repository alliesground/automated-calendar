class AddUserRefToGoogleConfigs < ActiveRecord::Migration[6.0]
  def change
    add_reference :google_configs, :user, null: false, foreign_key: true, index: true
  end
end
