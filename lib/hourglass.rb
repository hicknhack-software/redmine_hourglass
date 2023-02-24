module Hourglass
  NAMESPACE = name.downcase.to_sym
  PLUGIN_NAME = "redmine_#{NAMESPACE}".to_sym
  PLUGIN_ROOT = Pathname.new(File.join File.dirname(__FILE__), '..').cleanpath

  VERSION = '1.3.0-dev'

  def self.redmine_has_advanced_queries?
    Redmine::VERSION::MAJOR > 3 || (Redmine::VERSION::MAJOR == 3 && Redmine::VERSION::MINOR >= 4)
  end
end

Dir.glob File.join(Hourglass::PLUGIN_ROOT, 'config', 'initializers', '*'), &method(:require)

if Rails.version >= "5" and Rails.configuration.eager_load
  Dir.glob(File.join(Hourglass::PLUGIN_ROOT, 'lib', 'hourglass', "**/*.rb")).sort.each(&method(:require))
end
