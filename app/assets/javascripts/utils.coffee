clearFlash = ->
  $('#content').find('.flash').remove()

showMessage = (message, type) ->
  clearFlash()
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

@chronos ?= {}
@chronos.Utils =
  clearFlash: clearFlash
  showDialog: showDialog
  showErrorMessage: showErrorMessage
  showNotice: showNotice

$ ->
  $(document)
  .on 'ajax:success', '.js-chronos-remote', ->
    location.reload()
  .on 'ajax:error', '.js-chronos-remote', (event, {responseJSON}) ->
    chronos.Utils.showErrorMessage responseJSON.message
