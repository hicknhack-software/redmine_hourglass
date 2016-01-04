# this file is not a patch for whole redmine but only an extension for the chronos plugin instance
module Chronos
  module RedminePatches
    module MirrorAssetsPatch
      extend ActiveSupport::Concern

      def mirror_assets
        super
        Chronos::Assets.compile if Rails.env.production?
      end
    end
  end
end
