timeTrackerTimerInterval = null

startTimeTrackerTimer = ->
  duration = moment.duration moment() - moment $('.time-tracker-control [name*=start]').val(), moment.ISO_8601

  numberToString = (number)->
    result = (Math.floor Math.abs number).toString()
    result = '0' + result if Math.abs(number) < 10
    result

  displayTime = ->
    durationString = [
      duration.asHours(),
      duration.asMinutes() % 60,
      duration.asSeconds() % 60
    ].map(numberToString).join(':')
    $('.time-tracker-control .input.js-running-time').html("#{if duration < 0 then '-' else ''} #{durationString}")

  displayTime()
  clearInterval timeTrackerTimerInterval if timeTrackerTimerInterval?
  timeTrackerTimerInterval = setInterval ->
    duration = moment.duration(duration.asSeconds() + 1, 'seconds')
    displayTime()
  , 1000

@hourglass ?= {}
@hourglass.Timer = {
  start: startTimeTrackerTimer
}
