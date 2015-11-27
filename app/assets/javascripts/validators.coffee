@chronos ?= {}
@chronos.FormValidator = do ->
  isEmpty = ($field) ->
    $field.val() is ''

  isNotEmpty = ($field) ->
    not isEmpty $field

  isFieldValid = ($field, $form) ->
    type = $field.attr('name').replace(/time_tracker\[([a-z_]*)]/, '$1')
    isRequired = $field.prop('required')

    condition = switch type
      when 'activity_id' then isEmpty($form.find('[name*=project_id]')) or isNotEmpty($field)
      when 'issue_id' then isEmpty($form.find('#issue_text')) or isNotEmpty($field)
      else
        true

    condition and (not isRequired or isNotEmpty($field))

  validateField = ($field) ->
    $form = $field.closest('form')
    $submit = $form.find(':submit')

    valid = isFieldValid $field, $form

    $field.toggleClass('invalid', not valid)
    $field.prev().toggleClass('invalid', not valid) if $field.attr('type') is 'hidden'
    $submit.attr('disabled', not valid)
    valid

  validateForm = ($form) ->
    console.log 'not implemented'

  return {
    validateField: validateField
    validateForm: validateForm
  }
