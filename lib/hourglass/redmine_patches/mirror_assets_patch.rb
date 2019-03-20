# this file is not a patch for whole redmine but only an extension for the hourglass plugin instance
module Hourglass
  module RedminePatches
    module MirrorAssetsPatch

      def mirror_assets
        super
        Hourglass::Assets.compile if Rails.env.production?
      end
    end
  end
end
