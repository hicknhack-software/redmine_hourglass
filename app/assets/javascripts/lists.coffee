$ ->
  $('.js-chronos-list')
    .on 'click', '.checkbox a', (event) ->
      event.preventDefault()
      toggleIssuesSelection @
    .find '.group'
      .on 'click', '.expander', (event) ->
        event.preventDefault()
        toggleRowGroup @
      .on 'click', 'a', (event) ->
        event.preventDefault()
        toggleAllRowGroups @

  $queryForm = $('#query_form')
  $queryForm
    .on 'click', 'legend', (event) ->
      event.preventDefault()
      toggleFieldset @
    .on 'click', '', (event) ->
      event.preventDefault()
    .on 'click', '', (event) ->
      event.preventDefault()
    .find '.buttons'
      .on 'click', '.js-query-apply', (event) ->
        event.preventDefault()
        $queryForm.submit()
      .on 'click', '.js-query-save', (event) ->
        event.preventDefault()
        $queryForm
          .attr('action', $(@).data('url'))
          .submit()
