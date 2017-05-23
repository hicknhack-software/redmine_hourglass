$.fn.addDateTimePicker = ->
  currentTime = moment.parseZone @.val()
  @.datetimepicker $.extend hourglass.TimepickerLocales,
    hour: currentTime.hour()
    minute: currentTime.minute()
    timezone: currentTime._tzm
    dateFormat: 'yy-mm-ddT'
    separator: ''
    timeFormat: 'HH:mmz'
    timeInput: true
    timeOnly: not @.hasClass('js-picker-with-date')
    timeOnlyShowDate: true
    showTimezone: false
    
clearFlash = ->
  $('#content').find('.flash').remove()

debounce = (func, threshold, execAsap) ->
  timeout = null
  (args...) ->
    obj = this
    delayed = ->
      func.apply(obj, args) unless execAsap
      timeout = null
    if timeout
      clearTimeout(timeout)
    else if (execAsap)
      func.apply(obj, args)
    timeout = setTimeout delayed, threshold || 100

showMessage = (message, type) ->
  clearFlash()
  if $.isArray message
    $('#content').prepend $('<div/>', class: "flash #{type}").html $('<ul/>').html $.map message, (msg) ->
      $('<li/>').text msg
  else
    $('#content').prepend $('<div/>', class: "flash #{type}").text message

showNotice = (message) ->
  showMessage message, 'notice'

showErrorMessage = (message) ->
  showMessage message, 'error'

showDialog = (className, $content, buttons = []) ->
  $('<div/>', class: className, title: $content.data('dialog-title'))
  .append $content.removeClass('hidden')
  .appendTo 'body'
  .dialog
    autoOpen: true
    resizable: false
    draggable: false
    modal: true
    width: 300
    buttons: buttons

formatDuration = (duration, unit = null) ->
  duration = moment.duration duration, unit unless moment.isDuration duration
  moment("1900-01-01 00:00:00").add(duration).format('HH:mm')

parseDuration = (durationString) ->
  [hours, minutes] = durationString.split(':')
  moment.duration(hours: hours, minutes: minutes)

@hourglass ?= {}
@hourglass.Utils =
  clearFlash: clearFlash
  debounce: debounce
  formatDuration: formatDuration
  parseDuration: parseDuration
  showDialog: showDialog
  showErrorMessage: showErrorMessage
  showNotice: showNotice

$ ->
  $(document)
  .on 'ajax:success', '.js-hourglass-remote', ->
    location.reload()
  .on 'ajax:error', '.js-hourglass-remote', (event, {responseJSON}) ->
    hourglass.Utils.showErrorMessage responseJSON.message
