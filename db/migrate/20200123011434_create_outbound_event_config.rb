class CreateOutboundEventConfig < ActiveRecord::Migration[6.0]
  def change
    create_table :outbound_event_configs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :google_calendar, null: false, foreign_key: true
      t.references :receiver, references: :users, null: false, foreign_key: { to_table: 'users' }
    end
  end
end
