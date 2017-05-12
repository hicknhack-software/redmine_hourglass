JsRoutes.setup do |config|
  config.include = [
      /#{Chronos::NAMESPACE}/
  ]
  config.compact = true
  config.namespace = "#{Chronos::NAMESPACE}Routes"
end

Chronos::Assets.precompile += %w(application.js application.css global.js global.css jqplot.js jqplot/jquery.jqplot.css time_start.png time_stop.png)
