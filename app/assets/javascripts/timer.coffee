timeTrackerTimerInterval = null

startTimeTrackerTimer = ->
  start = new Date $('.time-tracker-control .js-start').val()
  now = new Date()
  diff = Math.floor((now - start) / 1000)

  numberToString = (number)->
    if number < 10 then '0' + number.toString() else number.toString()

  displayTime = ->
    isNegative = diff < 0
    h = numberToString Math.floor Math.abs(diff / 3600)
    m = numberToString Math.floor Math.abs(diff % 3600 / 60)
    s = numberToString Math.floor Math.abs(diff % 3600 % 60)
    $('.time-tracker-control .input.js-running-time').html("#{if isNegative then '-' else ''} #{h}:#{m}:#{s}")

  displayTime()
  clearInterval timeTrackerTimerInterval if timeTrackerTimerInterval?
  timeTrackerTimerInterval = setInterval ->
    diff += 1
    displayTime()
  , 1000

@chronos ?= {}
@chronos.Timer = {
  start: startTimeTrackerTimer
}
