JsRoutes.setup do |config|
  config.include = [
      /#{Hourglass::NAMESPACE}/
  ]
  config.module_type = nil
  config.compact = true
  config.namespace = "#{Hourglass::NAMESPACE}Routes"
end

Hourglass::Assets.precompile += %w(
  application.js application.css
  global.js global.css
  swagger.js swagger.css swagger-print.css swagger-ui/images/*
  jqplot.js jqplot/jquery.jqplot.css
  icons/*.png
)
