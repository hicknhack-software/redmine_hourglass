clearFlash = ->
  $('#content').find('.flash').remove()

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

getCookie = (name) ->
  if name
    match = document.cookie.match new RegExp("#{name}=(.*?)(?:;|$)")
    if match
      return unescape match[1].replace(/\+/g, '%20')

setCookie = (name, value, timeout) ->
  if name
    if timeout
      date = new Date()
      date.setTime date.getTime() + timeout
      expires = "; expires=#{date.toGMTString()}"
    else
      expires = ''
    document.cookie = "#{name}=#{escape(value)}#{expires}; path=/"

@hourglass ?= {}
@hourglass.Utils =
  clearFlash: clearFlash
  formatDuration: formatDuration
  parseDuration: parseDuration
  showDialog: showDialog
  showErrorMessage: showErrorMessage
  showNotice: showNotice
  getCookie: getCookie
  setCookie: setCookie

$ ->
  $(document)
  .on 'ajax:success', '.js-hourglass-remote', ->
    location.reload()
  .on 'ajax:error', '.js-hourglass-remote', (event) ->
    [responseJSON, status, xhr] = event.detail
    hourglass.Utils.showErrorMessage responseJSON.message
  .on 'click', '.js-toggle', ->
    $($(@).data('target')).toggleClass 'hidden'
