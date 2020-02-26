class IndexGoogleCalendarsOnUniqueLowercaseName < ActiveRecord::Migration[6.0]
  def up
    execute "CREATE UNIQUE INDEX index_google_calendars_on_lowercase_name
             ON google_calendars USING btree (lower(name));"
  end

  def down
    execute "DROP INDEX index_google_calendars_on_lowercase_name;"
  end
end
