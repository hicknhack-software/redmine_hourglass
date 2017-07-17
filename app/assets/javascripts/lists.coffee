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
  $form.closest('table').find(".#{type}-form").each (i) ->
    $form = $(@)
    entry = {}
    for param in $form.find('.form-field').find('input, select, textarea').serializeArray()
      entry[param.name.replace /[a-z_]*\[([a-z_]*)]/, '$1'] = param.value
    entries[$form.data('id-for-bulk-edit') || "new#{i}"] = entry
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
        hourglass.Utils.showErrorMessage responseJSON.message
  else
    alert 'Not yet implemented'

checkForMultiForm = ($row, $formRow)->
  type = $formRow.find('form').data('formType')
  $table = $row.closest('table')
  $visibleForms = $table.find(".#{type}-form")
  if $visibleForms.length > 1
    $visibleForms.find('[name=commit]').addClass('hidden')
    $visibleForms.find('.js-bulk-edit').addClass('hidden').last().removeClass('hidden')
    $visibleForms.find('.js-not-in-multi').prop('disabled', true)
  else
    $visibleForms.find('[name=commit]').removeClass('hidden')
    $visibleForms.find('.js-bulk-edit').addClass('hidden')
    $visibleForms.find('.js-not-in-multi').prop('disabled', false)

showInlineForm = (event, response) ->
  $row = $(@).closest 'tr'
  $row.addClass('hidden')
  $formRow = $row.clone().removeClass('hidden')
  tdCount = $formRow.find('td').toArray().reduce((total, elem) ->
    total + (parseInt(elem.colSpan) || 1)
  , 0) - 1
  $formRow
  .removeClass 'hascontextmenu context-menu-selection'
  .empty()
  .append $('<td/>', class: 'hide-when-print')
  .append $('<td/>', colspan: tdCount).append response
  .insertAfter $row
  $formRow.find('.js-validate-limit').each addStartStopLimitMoments
  $durationField = $formRow.find('.js-duration')
  $durationField.val hourglass.Utils.formatDuration parseFloat($durationField.val()), 'hours' if $durationField
  checkForMultiForm $row, $formRow

showInlineFormMulti = (event, response) ->
  $(response).each ->
    showInlineForm.call $("##{$(@).data('id-for-bulk-edit')} .js-show-inline-form").get(), event, @
  window.contextMenuHide()

showInlineFormCreate = (event, response) ->
  showInlineForm.call $('.js-create-form-anchor').get(), event, response

hideInlineForm = (event) ->
  event.preventDefault()
  $formRow = $(@).closest('tr')
  $row = $formRow.prev()
  $formRow.remove()
  $row.removeClass('hidden')
  checkForMultiForm $row, $formRow

processErrorPageResponse = (event, {responseText}) ->
  if responseText
    $response = $(responseText)
    message = "#{$response.filter('h2').text()} - #{$response.filter('#errorExplanation').text()}"
    hourglass.Utils.showErrorMessage message

addStartStopLimitMoments = ->
  $field = $(@)
  $field.data 'mLimit', moment $field.val(), moment.ISO_8601 unless moment.isMoment($field.data('mLimit'))

# this is only needed for redmine > 3.4, but it doesn't hurt to have it in lower version too
window.oldContextMenuShow = window.contextMenuShow
window.contextMenuShow = (event) ->
  event.target = $('<div/>').appendTo $('<form/>', data: {'cm-url': hourglassRoutes.hourglass_ui_context_menu()})
  window.oldContextMenuShow event

$ ->
  $list = $('.hourglass-list')
  $list
  .on 'click', '.checkbox a', toggleAllCheckBoxes
  .on 'ajax:success', '.js-show-inline-form', showInlineForm
  .on 'ajax:error', '.js-show-inline-form', processErrorPageResponse
  .on 'click', '.js-hide-inline-form', hideInlineForm
  .on 'click', '.js-bulk-edit', submitMultiForm

  $(document)
  .on 'ajax:success', '.js-show-inline-form-multi', showInlineFormMulti
  .on 'ajax:success', '.js-create-record', showInlineFormCreate
  .on 'ajax:error', '.js-show-inline-form-multi, .js-create-record', processErrorPageResponse
  .on 'ajax:before', '.disabled[data-remote]', ->
    window.contextMenuHide()
    return false

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
