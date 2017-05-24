JsRoutes.setup do |config|
  config.include = [
      /#{Hourglass::NAMESPACE}/
  ]
  config.compact = true
  config.namespace = "#{Hourglass::NAMESPACE}Routes"
end

Hourglass::Assets.precompile += %w(application.js application.css global.js global.css jqplot.js jqplot/jquery.jqplot.css icons/*.png)
