updateTimeTrackerControlForm = (data) ->
  chronos.clearFlash()
  $.ajax
    url: chronosRoutes.chronos_time_tracker('current')
    type: 'put'
    data: data
    error: ({responseJSON}) ->
      chronos.showErrorMessage responseJSON.message

$ ->
  $('.time-tracker-control').on 'change', (e) ->
    data = {}
    $target = $(e.target)
    $field = if $target.hasClass('js-linked-with-hidden')
      $target_id = $target.next()
      $target_id.val('') if $target.val() is ''
      $target_id
    else
      $target
    data[$field.attr('name')] = $field.val()
    updateTimeTrackerControlForm data
