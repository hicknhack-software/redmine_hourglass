#= require jqplot/jquery.jqplot
#= require jqplot/jqplot.barRenderer
#= require jqplot/jqplot.categoryAxisRenderer
#= require jqplot/jqplot.highlighter

$ ->
  if hourglass.jqplotData.data.length > 0
    $chartContainer = $('#chart-container').addClass('has-data')
    plot = $.jqplot 'chart-container', hourglass.jqplotData.data,
      seriesColors: (['#777', '#AAA'] if $chartContainer.hasClass('print'))
      stackSeries: true,
      seriesDefaults:
        renderer: $.jqplot.BarRenderer
        rendererOptions:
          fillToZero: true
          shadow: false
          barMargin: 2,
          varyBarColor: true,
      axes:
        xaxis:
          renderer: $.jqplot.CategoryAxisRenderer
          ticks: hourglass.jqplotData.ticks
        yaxis:
          min: 0
          pad: 1.2
          tickInterval: Math.max(Math.ceil(Math.max.apply(null, hourglass.jqplotData.data[0]) / 8), 1)
          tickOptions: {formatString: "%d #{hourglass.jqplotData.hourSign}"}
      grid:
        background: "#ffffff"
        shadow: false
      highlighter:
        tooltipContentEditor: (str, seriesIndex, pointIndex, plot) ->
          hourglass.jqplotData.highlightData[seriesIndex][pointIndex]
        show: true
        showMarker: false

  timeout = null
  $(window).resize ->
    clearTimeout timeout
    timeout = setTimeout  ->
      plot.replot resetAxes: true
    , 250
