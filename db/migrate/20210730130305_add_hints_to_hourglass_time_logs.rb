require 'hourglass/hourglass_migration'

class AddHintsToHourglassTimeLogs < HourglassMigration
  def change
    add_column :hourglass_time_logs, :hints, :text
  end
end
