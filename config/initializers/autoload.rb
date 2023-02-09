[
  %w(app models concerns),
  %w(app controllers concerns),
  %w(app policies),
  %w(app policies concerns)
].each do |path|
  Dir.glob(File.join(Hourglass::PLUGIN_ROOT, *path, "**/*.rb")).sort.each(&method(:require))
end
