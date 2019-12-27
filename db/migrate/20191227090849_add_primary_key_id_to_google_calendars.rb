class AddPrimaryKeyIdToGoogleCalendars < ActiveRecord::Migration[6.0]
  def change
    add_column :google_calendars, :id, :primary_key
  end
end
