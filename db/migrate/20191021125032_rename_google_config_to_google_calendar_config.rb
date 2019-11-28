class RenameGoogleConfigToGoogleCalendarConfig < ActiveRecord::Migration[6.0]
  def change
    rename_table :google_configs, :google_calendar_configs
  end
end
