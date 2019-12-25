class ChangeColumnNameInGoogleCalendar < ActiveRecord::Migration[6.0]
  def change
    rename_column :google_calendars, :summary, :name
  end
end
