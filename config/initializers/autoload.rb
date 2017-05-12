[
    %w(.. .. app models concerns),
    %w(.. .. app controllers concerns)
].each do |path|
  ActiveSupport::Dependencies.autoload_paths << Pathname.new(File.join(File.dirname(__FILE__), *path)).cleanpath
end
