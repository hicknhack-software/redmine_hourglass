class Hourglass::Assets < Sprockets::Environment
  include Singleton

  def initialize
    super Hourglass::PLUGIN_ROOT do |env|
      %w(app vendor).each do |dir|
        env.append_path File.join dir, 'assets'
        self.class.asset_directories.each do |asset_dir|
          env.append_path File.join dir, 'assets', asset_dir
        end
      end
      Rails.application.assets.paths.each do |path|
        env.append_path path
      end
      if Rails.env.production?
        env.js_compressor = Uglifier.new(harmony: true)
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
      asset_directory_map.values
    end

    def assets_directory_path
      File.join 'plugin_assets', Hourglass::PLUGIN_NAME.to_s
    end

    def asset_directory_map
      {
          javascript: 'javascripts',
          stylesheet: 'stylesheets',
          audio: 'audios',
          font: 'fonts',
          image: 'images',
          video: 'videos'
      }
    end

    def path(path, options = {})
      if options[:type].present?
        Rails.env.production? ? instance.find_asset(path).digest_path : File.join('/', assets_directory_path, asset_directory_map[options[:type]] || '', path)
      else
        path
      end
    end
  end
end
