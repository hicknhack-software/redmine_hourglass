# this file is not a patch for whole redmine but only an extension for the chronos plugin instance
module Chronos
  module RedminePatches
    module MirrorAssetsPatch
      extend ActiveSupport::Concern

      def mirror_assets
        super
        if Rails.env.production?
          manifest = Sprockets::Manifest.new Chronos::Assets.instance, File.join('public', 'plugin_assets', 'redmine_chronos')
          manifest.compile 'application.js', 'global.js', 'application.css', 'global.css'
        end
      end
    end
  end
end
