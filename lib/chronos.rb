module Chronos
  NAMESPACE = name.downcase.to_sym
  PLUGIN_NAME = "redmine_#{NAMESPACE}".to_sym

  VERSION = '1.0.0'
end

Dir.glob File.join(File.dirname(__FILE__), '..', 'config', 'initializers', '*'), &method(:require)
