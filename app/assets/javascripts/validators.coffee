isEmpty = ($field) ->
  $field.val() is ''

isNotEmpty = ($field) ->
  not isEmpty $field

isFieldValid = ($field, $form) ->
  type = $field.attr('name').replace(/[a-z_]*\[([a-z_]*)]/, '$1')
  isRequired = $field.prop('required')

  condition = switch type
    when 'activity_id' then isEmpty($form.find('[name*=project_id]')) or isNotEmpty($field)
    when 'issue_id' then isEmpty($form.find('#issue_text')) or isNotEmpty($field)
    when 'start'
      mStart = moment($field.val(), moment.ISO_8601)
      mStart.isValid() and not ($field.hasClass('js-validate-limit') and mStart.isBefore($field.data('mLimit')))
    when 'stop'
      mStop = moment($field.val(), moment.ISO_8601)
      mStop.isValid() and not ($field.hasClass('js-validate-limit') and mStop.isAfter($field.data('mLimit')))
    else
      true

  condition and (not isRequired or isNotEmpty($field))

validateField = ($field, $form = $field.closest('form')) ->
  $submit = $form.find(':submit')
  valid = isFieldValid $field, $form

  $field.toggleClass('invalid', not valid)
  $field.prev().toggleClass('invalid', not valid) if $field.attr('type') is 'hidden'
  $submit.attr('disabled', not valid)
  valid

validateForm = ($form) ->
  valid = true
  $submit = $form.find(':submit')
  $form.find('input, select, textarea').filter('[name]').each ->
    valid and validateField $(@), $form
  $submit.attr('disabled', not valid)
  valid

@chronos ?= {}
@chronos.FormValidator =
  validateField: validateField
  validateForm: validateForm
