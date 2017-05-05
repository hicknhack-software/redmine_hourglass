timeTrackerTimerInterval = null

startTimeTrackerTimer = ->
  duration = moment.duration moment() - moment $('.time-tracker-control [name*=start]').val()

  displayTime = ->
    $('.time-tracker-control .input.js-running-time').html(moment("1900-01-01 00:00:00").add(duration).format('HH:mm:ss'))

  displayTime()
  clearInterval timeTrackerTimerInterval if timeTrackerTimerInterval?
  timeTrackerTimerInterval = setInterval ->
    duration = moment.duration(duration.asSeconds() + 1, 'seconds')
    displayTime()
  , 1000

@chronos ?= {}
@chronos.Timer = {
  start: startTimeTrackerTimer
}
