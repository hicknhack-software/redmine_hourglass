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
    $target = $target.next() if $target.hasClass('js-linked-with-hidden')
    data[$target.attr('name')] = $target.val()
    updateTimeTrackerControlForm data
