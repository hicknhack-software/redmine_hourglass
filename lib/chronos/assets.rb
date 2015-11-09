class Chronos::Assets < Sprockets::Environment
  include Singleton

  def initialize
    super File.join(File.dirname(__FILE__), '..', '..') do |env|
      env.append_path 'app/assets/javascripts'
      env.append_path 'app/assets/stylesheets'
      if Rails.env.production?
        env.js_compressor  = Uglifier.new
        env.css_compressor  = CSSminify.new
      end
    end
  end

  def compress_and_compile
  end
end