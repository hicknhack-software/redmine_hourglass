class Chronos::RedmineHooks < Redmine::Hook::ViewListener
  def view_issues_show_description_bottom(context = {})
    load_assets context[:hook_caller]
    load_chronos_helper context[:hook_caller]
    context[:controller].render_to_string partial: 'hooks/issue_actions'
  end
  def view_issues_index_bottom(context = {})
    load_assets context[:hook_caller]
  end

  def view_issues_context_menu_start(context = {})
    load_chronos_helper context[:hook_caller]
    context[:controller].render_to_string partial: 'hooks/issue_actions'
  end

  def self.load!
    #load hook specific stuff
  end

  private
  def load_assets(view_context)
    view_context.content_for :header_tags, javascript_include_tag('global', plugin: 'redmine_chronos')
    view_context.content_for :header_tags, stylesheet_link_tag('global', plugin: 'redmine_chronos')
  end

  def load_chronos_helper(view_context)
    view_context.class.send :include, Chronos::ApplicationHelper
  end
end
