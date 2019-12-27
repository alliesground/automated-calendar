class RemoveColumnIdFromGoogleCalendars < ActiveRecord::Migration[6.0]
  def change
    remove_column :google_calendars, :id
  end
end
