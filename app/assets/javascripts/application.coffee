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
$ ->
  $('.js-issue-autocompletion').autocomplete
    source: chronosRoutes.chronos_issue_completion(),
    minLength: 1,
    autoFocus: true,
    response: (event, ui) ->
      $(event.target).next().val('')
    select: (event, ui) ->
      event.preventDefault()
      $(event.target)
        .trigger('change')
        .closest('form').find('[name*=project_id]').val(ui.item.project_id)
    focus: (event, ui) ->
      event.preventDefault()
      $(event.target)
        .val(ui.item.label)
        .next().val(ui.item.issue_id)
