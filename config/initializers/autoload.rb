[
  %w(app models concerns),
  %w(app controllers concerns),
  %w(app policies),
  %w(app policies concerns)
].each do |path|
  if Rails.version >= "6" 
    Rails.autoloaders.main.push_dir File.join(Hourglass::PLUGIN_ROOT, *path)
  elsif Rails.version >= "5" and Rails.configuration.eager_load
    Dir.glob(File.join(Hourglass::PLUGIN_ROOT, *path, "**/*.rb")).sort.each(&method(:require))    
  else
    ActiveSupport::Dependencies.autoload_paths << File.join(Hourglass::PLUGIN_ROOT, *path)
  end
end
