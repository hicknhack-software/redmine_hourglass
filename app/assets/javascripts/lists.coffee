toggleAllCheckBoxes = (event) ->
  event.preventDefault()
  $boxes = $(@).closest('table').find('input[type=checkbox]')
  all_checked = true
  $boxes.each -> all_checked = all_checked && $(@).prop('checked')
  $boxes.each ->
    $(@)
    .prop('checked', !all_checked)
    .parents('tr')
    .toggleClass('context-menu-selection', !all_checked)

multiFormParameters = ($form) ->
  entries = {}
  type = $form.data('formType')
  $form.closest('table').find(".#{type}-form").each ->
    $form = $(@)
    entry = {}
    for param in $form.find('.form-field').find('input, select, textarea').serializeArray()
      entry[param.name.replace /[a-z_]*\[([a-z_]*)]/, '$1'] = param.value
    entries[$form.data('id-for-bulk-edit')] = entry
  entries

submitMultiForm = (event) ->
  event.preventDefault()
  $button = $(@)
  $form = $button.closest('form')
  entries = multiFormParameters $form
  url = $button.data('url')
  if url?
    data = {}
    data[$button.data('name')] = entries
    $.ajax
      url: url
      method: 'post'
      data: data
      success: ->
        location.reload()
      error: ({responseJSON}) ->
        chronos.Utils.showErrorMessage responseJSON.message
  else
    alert 'Not yet implemented'

checkForMultiForm = ($row, $formRow)->
  type = $formRow.find('form').data('formType')
  $table = $row.closest('table')
  $visibleForms = $table.find(".#{type}-form")
  if $visibleForms.length > 1
    $visibleForms.find('[name=commit]').addClass('hidden')
    $visibleForms.find('.js-bulk-edit').addClass('hidden').last().removeClass('hidden')
  else
    $visibleForms.find('[name=commit]').removeClass('hidden')
    $visibleForms.find('.js-bulk-edit').addClass('hidden')

showInlineForm = (event, response) ->
  $row = $(@).closest 'tr'
  $formRow = $row.clone()
  $row.hide()
  tdCount = $formRow.find('td').length - 1
  $formRow
  .removeClass 'hascontextmenu'
  .empty()
  .append $('<td/>', class: 'hide-when-print')
  .append $('<td/>', colspan: tdCount).append response
  .insertAfter $row
  $formRow.find('.js-validate-limit').each addStartStopLimitMoments
  checkForMultiForm $row, $formRow

hideInlineForm = (event) ->
  event.preventDefault()
  $formRow = $(@).closest('tr')
  $row = $formRow.prev()
  $formRow.remove()
  $row.show()
  checkForMultiForm $row, $formRow

processErrorPageResponse = (event, {responseText}) ->
  if responseText
    $response = $(responseText)
    message = "#{$response.filter('h2').text()} - #{$response.filter('#errorExplanation').text()}"
    chronos.Utils.showErrorMessage message

addStartStopLimitMoments = ->
  $field = $(@)
  $field.data 'mLimit', moment($field.val()) unless moment.isMoment($field.data('mLimit'))

$ ->
  $list = $('.chronos-list')
  $list
  .on 'click', '.checkbox a', toggleAllCheckBoxes
  .on 'ajax:success', '.js-show-inline-form', showInlineForm
  .on 'ajax:error', '.js-show-inline-form', processErrorPageResponse
  .on 'click', '.js-hide-inline-form', hideInlineForm
  .on 'click', '.js-bulk-edit', submitMultiForm

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
