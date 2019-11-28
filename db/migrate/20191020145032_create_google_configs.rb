class CreateGoogleConfigs < ActiveRecord::Migration[6.0]
  def change
    create_table :google_configs do |t|
      t.string :access_token
      t.string :refresh_token
    end
  end
end
