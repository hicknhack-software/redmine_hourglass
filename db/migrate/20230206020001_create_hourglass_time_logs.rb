class CreateHourglassTimeLogs < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    create_table :hourglass_time_logs do |t|
      t.datetime :start, null: false
      t.datetime :stop, null: false
      t.string :comments
      t.belongs_to :user, null: false
      t.timestamps null: true
    end
    add_index :hourglass_time_logs, :user_id
  end
end
