$ ->
  $('.js-chronos-list')
    .on 'click', '.checkbox a', (event) ->
      event.preventDefault()
      toggleIssuesSelection @
    .find('.group')
      .on 'click', '.expander', (event) ->
        event.preventDefault()
        toggleRowGroup @
      .on 'click', 'a', (event) ->
        event.preventDefault()
        toggleAllRowGroups @
  $('#query_form')
    .on 'click', 'legend', (event) ->
      event.preventDefault()
      toggleFieldset @
