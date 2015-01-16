ActiveSupport::Dependencies.autoload_paths << File.join(File.dirname(__FILE__), '..', 'app', 'models', 'concerns')
ActiveSupport::Dependencies.autoload_paths << File.join(File.dirname(__FILE__), 'chronos')

module Chronos
  def self.settings
    Setting.plugin_redmine_chronos
  end
end