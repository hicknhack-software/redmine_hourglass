[
  %w(app models concerns),
  %w(app controllers concerns),
  %w(app policies),
  %w(app policies concerns),
  %w(lib hourglass)
].each do |path|
  ActiveSupport::Dependencies.autoload_paths << File.join(Hourglass::PLUGIN_ROOT, *path)
end
