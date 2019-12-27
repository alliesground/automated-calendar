class AddColumnRemoteIdToGoogleCalendars < ActiveRecord::Migration[6.0]
  def change
    add_column :google_calendars, :remote_id, :string
  end
end
