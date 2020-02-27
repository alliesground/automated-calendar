class UniqueCompositeIndexGoogleCalendarsOnLowercaseNameAndUserId < ActiveRecord::Migration[6.0]
  def up
    execute "CREATE UNIQUE INDEX unique_index_google_calendars_on_lowercase_name_and_user_id ON google_calendars USING btree (user_id, lower(name));"
  end

  def down
    execute "DROP INDEX unique_index_google_calendars_on_lowercase_name_and_user_id;"
  end
end
