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
    updateTimeTrackerControlForm $.param $(e.target)
