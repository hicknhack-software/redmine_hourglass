formFieldChanged = (event) ->
  data = {}
  $target = $(event.target)
  data[$target.attr('name')] = $target.val()
  chronos.Utils.clearFlash()
  $.ajax
    url: chronosRoutes.chronos_time_tracker('current')
    type: 'put'
    data: data
    error: ({responseJSON}) ->
      chronos.Utils.showErrorMessage responseJSON.message

$ ->
  $timeTrackerEditForm = $('.time-tracker-control').find('.edit-time-tracker-form')
  chronos.FormValidator.validateForm $timeTrackerEditForm

  $timeTrackerEditForm.on 'formfieldchanged', formFieldChanged
  .find('#time_tracker_start').on 'change', ->
    chronos.Timer.start()
