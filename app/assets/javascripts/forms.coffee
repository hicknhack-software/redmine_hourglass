initIssueAutoCompletion = ->
  $(@).autocomplete
    source: chronosRoutes.chronos_completion_issues(),
    minLength: 1,
    autoFocus: true,
    response: (event, ui) ->
      $(event.target).next().val('')
    select: (event, ui) ->
      event.preventDefault()
      $target = $(event.target).trigger('change')
      $target.closest('form').find('[name*=project_id]').val(ui.item.project_id).trigger('changefromissue')
    focus: (event, ui) ->
      event.preventDefault()
      $(event.target)
      .val(ui.item.label)
      .next().val(ui.item.issue_id)

updateActivityField = ($activityField, $projectField) ->
  selected_activity = $activityField.find("option:selected").text()
  $.ajax
    url: chronosRoutes.chronos_completion_activities()
    data:
      project_id: $projectField.val()
    success: (activities) ->
      $activityField.find('option[value!=""]').remove()
      for {id, name} in activities
        do ->
          $activityField.append $('<option/>', value: id).text(name)
          $activityField.val id if selected_activity is name
      chronos.FormValidator.validateField $activityField

formFieldChanged = (event) ->
  $target = $(event.target)
  $target = $target.next() if $target.hasClass('js-linked-with-hidden')
  chronos.FormValidator.validateField $target
  $target.trigger 'formfieldchanged'

startFieldChanged = (event) ->
  $startField = $(event.target)
  return if $startField.hasClass('invalid')
  $stopField = $startField.closest('form').find('[name*=stop]')
  chronos.FormValidator.validateField $stopField if $stopField.length > 0

stopFieldChanged = (event) ->
  $stopField = $(event.target)
  return if $stopField.hasClass('invalid')
  $startField = $stopField.closest('form').find('[name*=start]')
  chronos.FormValidator.validateField $startField

projectFieldChanged = (event) ->
  $projectField = $(@)
  $form = $projectField.closest('form')
  $issueTextField = $form.find('.js-issue-autocompletion')
  $activityField = $form.find('[name*=activity_id]')

  round = $projectField.find(':selected').data('round-default')
  $form.find('[type=checkbox][name*=round]').prop('checked', round) unless round is null
  sumsOnly = $projectField.find(':selected').data('round-sums-only')
  roundingDisabled = if sumsOnly is undefined then $projectField.val() is '' else sumsOnly
  $form.find('[type=checkbox][name*=round]').prop('disabled', roundingDisabled)
    .closest('.form-field').toggleClass('hidden', roundingDisabled)

  $issueTextField.val('').trigger('change') unless $issueTextField.val() is '' or event.type is 'changefromissue'
  chronos.FormValidator.validateField $projectField if event.type is 'changefromissue'
  updateActivityField $activityField, $projectField

issueFieldChanged = ->
  $issueTextField = $(@)
  $issueTextField.next().val('') if $issueTextField.val() is ''

split = (timeLogId, mSplitAt, insertNewBefore, round) ->
  $.ajax
    url: chronosRoutes.split_chronos_time_log timeLogId
    method: 'post'
    data:
      split_at: mSplitAt.toJSON()
      insert_new_before: insertNewBefore
      round: round

submit_without_split_checking = ($form) ->
  $form
  .removeClass('js-check-splitting')
  .submit()

addSplittingSuccessfulHandler = ($form, startJqXhr, stopJqXhr) ->
  if startJqXhr
    startJqXhr.done ->
      submit_without_split_checking $form
  else if stopJqXhr
    stopJqXhr.done ->
      submit_without_split_checking $form

addSplittingFailedHandler = (startJqXhr, stopJqXhr) ->
  if stopJqXhr
    stopJqXhr.fail ({responseJSON}) ->
      chronos.Utils.showErrorMessage responseJSON.message
  if startJqXhr
    startJqXhr.fail ({responseJSON}) ->
      chronos.Utils.showErrorMessage responseJSON.message

checkSplitting = ->
  $form = $(@)
  timeLogId = $form.data('timeLogId')
  $startField = $form.find('[name*=start]')
  $stopField = $form.find('[name*=stop]')
  mStart = moment $startField.val()
  mStop = moment $stopField.val()
  round = $form.find('[type=checkbox][name*=round]').prop('checked')
  stopJqXhr = if mStop.isBefore $stopField.data('mLimit')
    split timeLogId, mStop, false, round
  startJqXhr = if mStart.isAfter $startField.data('mLimit')
    if stopJqXhr
      stopJqXhr.then ->
        split timeLogId, mStart, true, round
    else
      split timeLogId, mStart, true, round

  addSplittingSuccessfulHandler $form, startJqXhr, stopJqXhr
  addSplittingFailedHandler startJqXhr, stopJqXhr

  return not (startJqXhr or stopJqXhr)

$ ->
  $(document)
  .on 'focus', '.js-issue-autocompletion:not(.ui-autocomplete-input)', initIssueAutoCompletion
  .on 'change', '.js-validate-form', formFieldChanged
  .on 'change changefromissue', '[name*=project_id]', projectFieldChanged
  .on 'change', '.js-issue-autocompletion', issueFieldChanged
  .on 'formfieldchanged', '[name*=start]', startFieldChanged
  .on 'formfieldchanged', '[name*=stop]', stopFieldChanged
  .on 'submit ajax:before', '.js-validate-form', (event) ->
    isFormValid = chronos.FormValidator.validateForm $(@)
    unless isFormValid
      event.preventDefault()
      event.stopPropagation()
    return isFormValid
  .on 'ajax:before', '.js-check-splitting', checkSplitting
