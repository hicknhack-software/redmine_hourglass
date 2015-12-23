module Chronos
  module RedminePatches
    module PluginPatch
      extend ActiveSupport::Concern

      included do
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
