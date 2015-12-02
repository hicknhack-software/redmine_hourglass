clearFlash = ->
  $('#content').find('.flash').remove()

showMessage = (message, type) ->
  clearFlash()
  $('#content').prepend $('<div/>', class: "flash #{type}").text message

showNotice = (message) ->
  showMessage message, 'notice'

showErrorMessage = (message) ->
  showMessage message, 'error'

@chronos ?= {}
@chronos.Utils =
  clearFlash: clearFlash
  showNotice: showNotice
  showErrorMessage: showErrorMessage

