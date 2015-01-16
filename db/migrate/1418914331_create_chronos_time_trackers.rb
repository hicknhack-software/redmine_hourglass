class CreateChronosTimeTrackers < ActiveRecord::Migration
  def change
    create_table :chronos_time_trackers do |t|
      t.datetime :start, null: false
      t.string :comments
      t.boolean :round
      t.belongs_to :user, null: false
      t.belongs_to :project
      t.belongs_to :issue
      t.belongs_to :activity
      t.timestamps
    end
    add_index :chronos_time_trackers, :user_id, unique: true
    add_index :chronos_time_trackers, :project_id
    add_index :chronos_time_trackers, :issue_id
    add_index :chronos_time_trackers, :activity_id
  end
end
