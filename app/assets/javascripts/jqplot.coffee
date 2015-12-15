#= require jqplot/jquery.jqplot
#= require jqplot/jqplot.barRenderer
#= require jqplot/jqplot.categoryAxisRenderer
#= require jqplot/jqplot.highlighter

$ ->
  if chronos.jqplotData.data.length > 0
    $chartContainer = $('#chart-container').addClass('has-data')
    plot = $.jqplot 'chart-container', [chronos.jqplotData.data],
      seriesColors: (['#999'] if $chartContainer.hasClass('print'))
      seriesDefaults:
        renderer: $.jqplot.BarRenderer
        rendererOptions:
          fillToZero: true
          shadow: false
          barMargin: 2
      axes:
        xaxis:
          renderer: $.jqplot.CategoryAxisRenderer
          ticks: chronos.jqplotData.ticks
        yaxis:
          autoscale: true
          min: 0
          pad: 1
          tickInterval: 1
          tickOptions: {formatString: "%d #{chronos.jqplotData.hourSign}"}
      grid:
        background: "#ffffff"
        shadow: false
      highlighter:
        tooltipContentEditor: (str, seriesIndex, pointIndex, plot) ->
          chronos.jqplotData.highlightData[pointIndex]
        show: true
        showMarker: false

  timeout = null
  $(window).resize ->
    clearTimeout timeout
    timeout = setTimeout  ->
      plot.replot resetAxes: true
    , 250
