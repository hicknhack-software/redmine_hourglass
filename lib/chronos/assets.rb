class Chronos::Assets < Sprockets::Environment
  include Singleton

  attr_accessor :precompile

  def initialize
    self.precompile = []
    super File.join(File.dirname(__FILE__), '..', '..') do |env|
      env.append_path 'app/assets/javascripts'
      env.append_path 'vendor/assets/javascripts'
      env.append_path 'app/assets/stylesheets'
      env.append_path 'vendor/assets/stylesheets'
      Rails.application.assets.paths.each do |path|
        env.append_path path
      end
      if Rails.env.production?
        env.js_compressor = :uglify
        env.css_compressor = :scss
      end
    end
  end

  class << self
    delegate :precompile, :precompile=, to: :instance

    def compile
      manifest.compile precompile
    end

    def manifest
      Sprockets::Manifest.new instance, File.join('public', 'plugin_assets', 'redmine_chronos')
    end
  end
end
