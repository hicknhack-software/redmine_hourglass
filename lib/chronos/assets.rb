class Chronos::Assets < Sprockets::Environment
  include Singleton

  def initialize
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
end
