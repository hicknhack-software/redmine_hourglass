module Chronos
  class IssueCompletionController < ApiBaseController
    accept_api_auth :index

    def index
      issue_arel = Issue.arel_table
      issues = Issue.visible.where(
                   issue_arel[:id].eq(params[:term].to_i)
                       .or(issue_arel[:id].matches("%#{params[:term]}%"))
                       .or(issue_arel[:subject].matches("%#{params[:term]}%"))
               )
      issue_list = issues.map do |issue|
        {label: "##{issue.id} #{issue.subject}", value: "#{issue.id}", data: "#{issue.subject}"}
      end
      respond_with_success issue_list
    end
  end
end
