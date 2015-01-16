class CreateChronosTimeLogs < ActiveRecord::Migration
  def change
    create_table :chronos_time_logs do |t|
      t.datetime :start, null: false
      t.datetime :stop, null: false
      t.string :comments
      t.belongs_to :user, null: false
      t.timestamps
    end
    add_index :chronos_time_logs, :user_id
  end
end
