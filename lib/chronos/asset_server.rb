class Chronos::AssetServer < Sprockets::Environment
  include Singleton

  def initialize
    super File.join(File.dirname(__FILE__), '..', '..') do |env|
      env.append_path 'app/assets/javascripts'
      env.append_path 'app/assets/stylesheets'
    end
  end
end