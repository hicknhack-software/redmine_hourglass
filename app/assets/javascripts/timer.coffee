timeTrackerTimerInterval = null

startTimeTrackerTimer = ->
  start = new Date($('.time-tracker-control .start').data('start-in-ms') * 1000)
  now = new Date()
  diff = Math.floor((now - start) / 1000)

  numberToString = (number)->
    if number < 10 then '0' + number.toString() else number.toString()
  displayTime = ->
    h = numberToString Math.floor(diff / 3600)
    m = numberToString Math.floor(diff % 3600 / 60)
    s = numberToString Math.floor(diff % 3600 % 60)
    $('.time-tracker-control .input.running-time').html h + ':' + m + ':' + s

  displayTime()
  window.clearInterval timeTrackerTimerInterval if timeTrackerTimerInterval?
  timeTrackerTimerInterval = window.setInterval ->
    diff += 1
    displayTime()
  , 1000

$ ->
  startTimeTrackerTimer()
