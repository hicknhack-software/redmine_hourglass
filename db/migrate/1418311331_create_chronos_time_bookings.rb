class CreateChronosTimeBookings < ActiveRecord::Migration
  def change
    create_table :chronos_time_bookings do |t|
      t.datetime :start, null: false
      t.datetime :stop, null: false
      t.belongs_to :time_log, null: false
      t.belongs_to :time_entry, null: false
      t.timestamps
    end
    add_index :chronos_time_bookings, :time_log_id
    add_index :chronos_time_bookings, :time_entry_id, unique: true
  end
end
