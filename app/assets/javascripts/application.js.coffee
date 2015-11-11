$ ->
  $('.start').click ->
    $.ajax
      method: 'POST'
      url: '/chronos/time_tracker/start'
      success: (data) ->
        console.log data;
      error: (xhr) ->
        console.log xhr.responseJSON;
  $('.stop').click ->
    $.ajax
      method: 'POST'
      url: '/chronos/time_tracker/current/stop'
      data: {_method: 'delete'}
      success: (data) ->
        console.log data;
      error: (xhr) ->
        console.log xhr.responseJSON;