require 'hourglass/hourglass_migration'

class AddHintsToHourglassTimeTrackers < HourglassMigration
  def change
    add_column :hourglass_time_trackers, :hints, :text
  end
end
