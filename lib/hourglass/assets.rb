class Hourglass::Assets < Sprockets::Environment
  include Singleton

  def initialize
    super File.join(File.dirname(__FILE__), '..', '..') do |env|
      %w(app vendor).each do |dir|
        self.class.asset_directories.each do |asset_dir|
          env.append_path File.join dir, 'assets', asset_dir
        end
      end
      Rails.application.assets.paths.each do |path|
        env.append_path path
      end
      if Rails.env.production?
        env.js_compressor = :uglify
        env.css_compressor = :scss
      end
    end
    context_class.class_eval do
      def asset_path(path, options = {})
        Hourglass::Assets.path path, options
      end
    end
  end

  class << self
    attr_writer :precompile

    def precompile
      @precompile ||= []
    end

    def compile
      manifest.compile precompile
    end

    def manifest
      Sprockets::Manifest.new instance, File.join('public', assets_directory_path)
    end

    def asset_directories
      STATIC_ASSET_DIRECTORIES.values + %w(javascripts stylesheets)
    end

    def assets_directory_path
      File.join 'plugin_assets', Hourglass::PLUGIN_NAME.to_s
    end

    STATIC_ASSET_DIRECTORIES = {
        audio: 'audios',
        font: 'fonts',
        image: 'images',
        video: 'videos'
    }

    def path(path, options = {})
      if Rails.env.production?
        instance.find_asset(path).digest_path
      else
        folder = STATIC_ASSET_DIRECTORIES[options[:type]] || ''
        File.join '..', folder, path
      end
    end
  end
end
