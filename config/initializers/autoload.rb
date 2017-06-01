[
    %w(app models concerns),
    %w(app controllers concerns)
].each do |path|
  ActiveSupport::Dependencies.autoload_paths << File.join(Hourglass::PLUGIN_ROOT, *path)
end
