isEmpty = ($field) ->
  $field.val() is ''

isNotEmpty = ($field) ->
  not isEmpty $field

isValidTimeField = ($field, limitConditionCallback, additionalConditionCallback) ->
  mTime = moment($field.val(), moment.ISO_8601)
  mTime.isValid() and
    (not $field.hasClass('js-validate-limit') or limitConditionCallback(mTime)) and
    additionalConditionCallback(mTime)

isFieldValid = ($field, $form) ->
  type = $field.attr('name').replace(/[a-z_]*\[([a-z_]*)]/, '$1')
  isRequired = $field.prop('required')

  condition = switch type
    when 'activity_id' then isEmpty($form.find('[name*=project_id]')) or isNotEmpty($field)
    when 'issue_id' then isEmpty($form.find('#issue_text')) or isNotEmpty($field)
    when 'start'
      isValidTimeField $field,
        (mStart) ->
          not mStart.isBefore $field.data('mLimit')
        (mStart) ->
          stopField = $form.find('[name*=stop]')
          stopField.length is 0 or mStart.isBefore moment(stopField.val(), moment.ISO_8601)
    when 'stop'
      isValidTimeField $field,
        (mStop) ->
          not mStop.isAfter $field.data('mLimit')
        (mStop) ->
          startField = $form.find('[name*=start]')
          startField.length is 0 or mStop.isAfter moment(startField.val(), moment.ISO_8601)
    else
      true

  condition and (not isRequired or isNotEmpty($field))

toggle_submit = ($form, valid) ->
  $form.find(':submit').attr('disabled', not valid)

all_form_fields = ($form, filter = null) ->
  $fields = $form.find('input, select, textarea')
  if filter? then $fields.filter filter else $fields

validateField = ($field, $form = $field.closest('form')) ->
  valid = isFieldValid $field, $form

  $field.toggleClass('invalid', not valid)
  $field.prev().toggleClass('invalid', not valid) if $field.attr('type') is 'hidden'
  toggle_submit $form, all_form_fields($form, '.invalid').length is 0
  valid

validateForm = ($form) ->
  valid = true
  all_form_fields($form, '[name]').each ->
    valid = valid and validateField $(@), $form
  toggle_submit $form, valid
  valid

@chronos ?= {}
@chronos.FormValidator =
  validateField: validateField
  validateForm: validateForm
