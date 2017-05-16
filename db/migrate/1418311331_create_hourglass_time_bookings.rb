class CreateHourglassTimeBookings < ActiveRecord::Migration
  def change
    create_table :hourglass_time_bookings do |t|
      t.datetime :start, null: false
      t.datetime :stop, null: false
      t.belongs_to :time_log, null: false
      t.belongs_to :time_entry, null: false
      t.timestamps null: true
    end
    add_index :hourglass_time_bookings, :time_log_id
    add_index :hourglass_time_bookings, :time_entry_id, unique: true
  end
end
