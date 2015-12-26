class Chronos::RedmineHooks < Redmine::Hook::ViewListener
  def self.load!
    render_on :view_issues_show_description_bottom, partial: 'hooks/issue_actions'
  end
end
