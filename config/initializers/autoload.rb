[
  %w(app models concerns),
  %w(app controllers concerns),
  %w(app policies),
  %w(app policies concerns)
].each do |path|
  if Rails.version >= "5" and Rails.configuration.eager_load
    Dir.glob(File.join(Hourglass::PLUGIN_ROOT, *path, "**/*.rb")).sort.each(&method(:require))
  else
    Rails.autoloaders.main.push_dir File.join(Hourglass::PLUGIN_ROOT, *path)
  end
end
