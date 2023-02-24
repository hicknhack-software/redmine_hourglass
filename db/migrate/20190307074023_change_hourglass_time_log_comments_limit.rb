class ChangeHourglassTimeLogCommentsLimit < Hourglass::Migration
  def up
    change_column :hourglass_time_logs, :comments, :string, limit: 1024
  end

  def down
    change_column :hourglass_time_logs, :comments, :string
  end
end
