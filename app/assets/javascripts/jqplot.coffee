#= require jqplot/jquery.jqplot
#= require jqplot/jqplot.barRenderer
#= require jqplot/jqplot.categoryAxisRenderer
#= require jqplot/jqplot.highlighter

showToolTip = (str, seriesIndex, pointIndex, plot) ->
  point = highlightData[pointIndex]
  point[0] + this.tooltipSeparator + timeDist2String(point[1] * 3600)

timeDist2String = (dist) ->
  h = Math.floor(dist / 3600)
  m = Math.floor((dist - h * 3600) / 60)
  return h.toString() + "<%= l(:tt_hours_sign) %> " + m.toString() + "<%= l(:tt_min_sign) %>"

$ ->
  if data.length > 0
    plot = $.jqplot 'chart-container', [data],
      seriesDefaults:
        renderer: $.jqplot.BarRenderer
        rendererOptions:
          fillToZero: true,
          shadow: false,
          barMargin: 2
      axes:
        xaxis:
          renderer: $.jqplot.CategoryAxisRenderer,
          ticks: ticks
        yaxis:
          autoscale: true,
          min: 0,
          pad: 1,
          tickInterval: 1,
          tickOptions: {formatString: '%d<%= l(:tt_hours_sign) %>'}
      grid:
        background: "#ffffff",
        shadow: false
      highlighter:
        tooltipContentEditor: showToolTip
        show: true,
        showMarker: false

  $(window).resize ->
    plot.replot resetAxes: true
