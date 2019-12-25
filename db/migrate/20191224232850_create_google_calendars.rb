class CreateGoogleCalendars < ActiveRecord::Migration[6.0]
  def change
    create_table :google_calendars, id: false do |t|
      t.string :id, null: false
      t.references :user, null: false, foreign_key: true
      t.string :summary
      t.string :description
    end

    add_index :google_calendars, :id, unique: true
  end
end
