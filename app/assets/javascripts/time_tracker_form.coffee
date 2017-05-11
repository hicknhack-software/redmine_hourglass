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
  $timeTrackerControl = $('.time-tracker-control')
  chronos.Timer.start() if $timeTrackerControl.length > 0
  $timeTrackerEditForm = $timeTrackerControl.find('.edit-time-tracker-form')
  chronos.FormValidator.validateForm $timeTrackerEditForm

  $timeTrackerEditForm.on 'formfieldchanged', chronos.Utils.debounce(formFieldChanged, 500)
  .find('#time_tracker_start')
  .on 'change', ->
    chronos.Timer.start()
  .addDateTimePicker()

  $timeTrackerEditForm.find('.js-stop-new').on 'click', ->
    $timeTrackerEditForm.data('start-new', true)

  $timeTrackerEditForm.on 'ajax:success', (event) ->
    if $timeTrackerEditForm.data('start-new')
      event.stopPropagation()
      $timeTrackerEditForm.data('start-new', false)
      $.ajax
        url: chronosRoutes.start_chronos_time_trackers()
        type: 'post'
        complete: () ->
          location.reload()
