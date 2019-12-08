class AddConstraintsToEvents < ActiveRecord::Migration[6.0]
  def change
    change_column_null :events, :title, false
    change_column_null :events, :start_time, false
    change_column_null :events, :end_time, false
  end
end
