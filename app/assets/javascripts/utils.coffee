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

detranslateDateTime = (durationString) ->
  window.hourglass.DateTimeStrings.reduce (a, [pattern, replace]) ->
    a.replace pattern, replace
  , durationString

@hourglass ?= {}
@hourglass.Utils =
  clearFlash: clearFlash
  debounce: debounce
  detranslateDateTime: detranslateDateTime
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
