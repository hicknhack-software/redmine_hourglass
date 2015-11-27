#= require jsroutes.js.erb
#= require time_tracker_form
#= require validators
#= require timer

@chronos ?= {}
@chronos.Utils = {
  clearFlash: ->
    $('#content').find('.flash').remove()

  showMessage: (message, type) ->
    @clearFlash()
    $('#content').prepend $('<div/>', class: "flash #{type}").text message

  showNotice: (message) ->
    @showMessage message, 'notice'

  showErrorMessage: (message) ->
    @showMessage message, 'error'

  updateActivityField: ($activityField) ->
    $projectField = $activityField.closest('form').find('[name*=project_id]')
    selected_activity = $activityField.find("option:selected").text()
    $.ajax
      url: chronosRoutes.chronos_completion_activities()
      data:
        project_id: $projectField.val()
      success: (activities) ->
        $activityField.find('option[value!=""]').remove()
        for {id, name} in activities
          do ->
            $activityField.append $('<option/>', value: id).text(name)
            $activityField.val id if selected_activity is name
        chronos.FormValidator.validateField $activityField
}
$ ->
  $('.js-issue-autocompletion').autocomplete
    source: chronosRoutes.chronos_completion_issues(),
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
