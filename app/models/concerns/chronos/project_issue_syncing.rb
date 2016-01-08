module Chronos::ProjectIssueSyncing
  extend ActiveSupport::Concern

  included do
    before_save :sync_issue_and_project
  end

  def sync_issue_and_project
    self.project_id = issue.project_id if issue.present?
  end
end
