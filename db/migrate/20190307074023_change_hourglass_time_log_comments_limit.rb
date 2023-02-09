class ChangeHourglassTimeLogCommentsLimit < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def up
    change_column :hourglass_time_logs, :comments, :string, limit: 1024
  end

  def down
    change_column :hourglass_time_logs, :comments, :string
  end
end
