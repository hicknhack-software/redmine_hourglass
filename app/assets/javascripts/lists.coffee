$ ->
  $list = $('.chronos-list')
  $list
    .on 'click', '.checkbox a', (event) ->
      event.preventDefault()
      toggleIssuesSelection @

  $list.find '.actions'
    .on 'ajax:success', '.js-replace-entry', (event, response) ->
      $row = $(@).closest 'tr'
      $formRow = $row.clone()
      $formRow
        .removeClass 'hascontextmenu'
        .addClass 'inline-form'
        .empty()
        .append response
      $row
        .hide()
        .after $formRow
    .on 'ajax:error', '.js-replace-entry', (event, response) ->
      console.log response

  $list.find '.group'
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

  $queryForm.find '.buttons'
    .on 'click', '.js-query-apply', (event) ->
      event.preventDefault()
      $queryForm.submit()
    .on 'click', '.js-query-save', (event) ->
      event.preventDefault()
      $this = $(@)
      $queryForm
        .attr 'action', $this.data('url')
        .append $('<input/>', type: 'hidden', name: 'query_class').val($this.data('query-class'))
        .submit()
