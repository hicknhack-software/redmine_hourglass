addError = ($field, msg) ->
  errors = getErrors $field
  errors.push "[#{$field.closest('.form-field').find('label').text()}]: #{window.hourglass.errorMessages[msg] || msg}"
  $field.data 'errors', errors

getErrors = ($field) ->
  $field.data('errors') || []

clearErrors = ($field) ->
  $field.data 'errors', null

isEmpty = ($field) ->
  $field.val() is ''

validatePresence = ($field) ->
  addError $field, 'empty' if isEmpty $field

validateByType = (type, $field, $form) ->
  switch type
    when 'activity_id'
      validatePresence $field unless isEmpty $form.find('[name*=project_id]')
    when 'issue_id'
      validatePresence $field unless isEmpty $form.find('#issue_text')
    when 'start'
      mStart = moment $field.val(), moment.ISO_8601
      addError $field, 'invalid' unless mStart.isValid()
      addError $field, 'exceedsLimit' if $field.hasClass('js-validate-limit') and mStart.isBefore $field.data('mLimit')
      $stopField = $form.find('[name*=stop]')
      break if $stopField.length is 0
      mStop = moment $stopField.val(), moment.ISO_8601
      if $field.hasClass('js-allow-zero-duration')
        addError $field, 'invalidDuration' if mStart.isAfter mStop
      else
        addError $field, 'invalidDuration' if mStart.isSameOrAfter mStop
    when 'stop'
      mStop = moment $field.val(), moment.ISO_8601
      addError $field, 'invalid' unless mStop.isValid()
      addError $field, 'exceedsLimit' if $field.hasClass('js-validate-limit') and mStop.isAfter $field.data('mLimit')
      $startField = $form.find('[name*=start]')
      break if $startField.length is 0
      mStart = moment $startField.val(), moment.ISO_8601
      if $field.hasClass('js-allow-zero-duration')
        addError $field, 'invalidDuration' if mStart.isAfter mStop
      else
        addError $field, 'invalidDuration' if mStart.isSameOrAfter mStop

validateField = ($field, $form) ->
  clearErrors $field
  validatePresence $field if $field.prop('required')
  name = $field.attr('name')
  validateByType name.replace(/[a-z_]*\[([a-z_]*)]/, '$1'), $field, $form if name?

  hasErrors = getErrors($field).length > 0
  $field.toggleClass('invalid', hasErrors)
  $field.prev().toggleClass('invalid', hasErrors) if $field.attr('type') is 'hidden'

all_form_fields = ($form, filter = null) ->
  $fields = $form.find('input, select, textarea')
  if filter? then $fields.filter filter else $fields

processValidation = ($form) ->
  hourglass.Utils.clearFlash()
  $invalidFields = all_form_fields $form, '.invalid'
  hourglass.Utils.showErrorMessage $invalidFields.map( -> getErrors $(@)).get() if $invalidFields.length > 0
  $form.find(':submit').attr('disabled', $invalidFields.length > 0)

validateSingleField = ($field, $form = $field.closest('form')) ->
  validateField $field, $form
  processValidation $form

validateForm = ($form) ->
  all_form_fields($form, '[name]').each ->
    validateField $(@), $form
  processValidation $form

@hourglass ?= {}
@hourglass.FormValidator =
  validateField: validateSingleField
  isFieldValid: ($field, args...) ->
    validateSingleField $field, args...
    getErrors($field).length is 0
  validateForm: validateForm
