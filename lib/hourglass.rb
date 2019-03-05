module Hourglass
  NAMESPACE = name.downcase.to_sym
  PLUGIN_NAME = "redmine_#{NAMESPACE}".to_sym
  PLUGIN_ROOT = Pathname.new(File.join File.dirname(__FILE__), '..').cleanpath

  VERSION = '1.0.1'

  def self.redmine_has_advanced_queries?
    Redmine::VERSION::MAJOR > 3 || (Redmine::VERSION::MAJOR == 3 && Redmine::VERSION::MINOR >= 4)
  end
end

Dir.glob File.join(Hourglass::PLUGIN_ROOT, 'config', 'initializers', '*'), &method(:require)
