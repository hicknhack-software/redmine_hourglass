ActiveSupport::Dependencies.autoload_paths << File.join(File.dirname(__FILE__), '..', 'app', 'models', 'concerns')
ActiveSupport::Dependencies.autoload_paths << File.join(File.dirname(__FILE__), 'chronos')

# load redmine patches
Dir[File.expand_path(File.dirname(__FILE__) + '/redmine_patches/*.rb')].each { |f| require f }

module Chronos
  def self.settings
    Setting.plugin_redmine_chronos
  end
end