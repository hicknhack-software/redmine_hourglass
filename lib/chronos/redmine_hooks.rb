class Chronos::RedmineHooks < Redmine::Hook::ViewListener
  def view_issues_show_description_bottom(context={})
    context[:hook_caller].content_for :header_tags, javascript_include_tag('application', plugin: 'redmine_chronos')
    context[:hook_caller].content_for :header_tags, stylesheet_link_tag('application', plugin: 'redmine_chronos')
    context[:hook_caller].class.send :include, Chronos::ApplicationHelper
    context[:controller].render_to_string partial: 'hooks/issue_actions'
  end

  def self.load!
    #load hook specific stuff
  end
end
