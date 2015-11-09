require_dependency 'redmine/plugin'
module RedminePatches
  module PluginPatch
    extend ActiveSupport::Concern

    included do
      class_eval do
        alias :old_mirror_assets :mirror_assets
        def mirror_assets
          if Rails.env.production?
            Chronos::Assets.compress_and_compile
          end
          old_mirror_assets
        end
      end
    end
  end
end

Redmine::Plugin.send :include, RedminePatches::PluginPatch
