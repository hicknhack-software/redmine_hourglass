updateTimeTrackerControlForm = (data) ->
  chronos.ajax
    url: '/chronos/time_trackers/current.json'
    type: 'put'
    data: data
    error: ({responseJSON}) ->
      console.log responseJSON

$ ->
  $('.time-tracker-control').on 'change', (e) ->
    updateTimeTrackerControlForm $.param $(e.target)
