#= require jsroutes.js.erb
#= require time_tracker_form
#= require timer

@chronos = {} unless @chronos?
@chronos = {
  clearFlash: ->
    $('#content').find('.flash').remove()

  showMessage: (message, type) ->
    @clearFlash()
    $('#content').prepend $('<div/>', class: "flash #{type}").text message

  showNotice: (message) ->
    @showMessage message, 'notice'

  showErrorMessage: (message) ->
    @showMessage message, 'error'
}
