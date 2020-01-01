class AddGoogleCalRefToGoogleEvents < ActiveRecord::Migration[6.0]
  def change
    add_reference :google_events, :google_calendar, null: false, foreign_key: true
  end
end
