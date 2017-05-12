module Chronos
  NAMESPACE = name.downcase.to_sym
  PLUGIN_NAME = "redmine_#{NAMESPACE}".to_sym
end

Dir.glob File.join(File.dirname(__FILE__), '..', 'config', 'initializers', '*'), &method(:require)
