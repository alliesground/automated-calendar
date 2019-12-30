class CreateGoogleEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :google_events do |t|
      t.string :remote_id
      t.references :event, null: false, foreign_key: true
    end
  end
end
