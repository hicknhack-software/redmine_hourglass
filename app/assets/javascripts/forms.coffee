initIssueAutoCompletion = ->
  $issueField = $(@)
  $projectField = $issueField.closest('form').find('[name*=project_id]')
  $issueField.autocomplete
    source: (request, response) ->
      $.ajax
        url: hourglassRoutes.hourglass_completion_issues(project_id: $projectField.val()),
        dataType: 'json',
        data: request
        success: response
    minLength: 1,
    autoFocus: true,
    response: (event, ui) ->
      $(event.target).next().val('')
    select: (event, ui) ->
      event.preventDefault()
      $issueField.trigger('change')
      $projectField.val(ui.item.project_id).trigger('changefromissue') if $projectField.val() isnt ui.item.project_id
    focus: (event, ui) ->
      event.preventDefault()
      $issueField
      .val(ui.item.label)
      .next().val(ui.item.issue_id)

updateActivityField = ($activityField, $projectField) ->
  selected_activity = $activityField.find("option:selected").text()
  $.ajax
    url: hourglassRoutes.hourglass_completion_activities()
    data:
      project_id: $projectField.val()
    success: (activities) ->
      $activityField.find('option[value!=""]').remove()
      for {id, name} in activities
        do ->
          $activityField.append $('<option/>', value: id).text(name)
          $activityField.val id if selected_activity is name
      hourglass.FormValidator.validateField $activityField

updateDurationField = ($startField, $stopField) ->
  start = moment($startField.val(), moment.ISO_8601)
  stop = moment($stopField.val(), moment.ISO_8601)
  $startField.closest('form').find('.js-duration').val hourglass.Utils.formatDuration moment.duration stop.diff(start)

formFieldChanged = (event) ->
  $target = $(event.target)
  $target = $target.next() if $target.hasClass('js-linked-with-hidden')
  hourglass.FormValidator.validateField $target
  $target.trigger 'formfieldchanged'

startFieldChanged = (event) ->
  $startField = $(event.target)
  return if $startField.hasClass('invalid')
  $stopField = $startField.closest('form').find('[name*=stop]')
  if $stopField.length > 0
    hourglass.FormValidator.validateField $stopField
    updateDurationField $startField, $stopField

stopFieldChanged = (event) ->
  $stopField = $(event.target)
  return if $stopField.hasClass('invalid')
  $startField = $stopField.closest('form').find('[name*=start]')
  hourglass.FormValidator.validateField $startField
  updateDurationField $startField, $stopField

durationFieldChanged = (event) ->
  $durationField = $(event.target)
  return if $durationField.hasClass('invalid')
  $startField = $durationField.closest('form').find('[name*=start]')
  $stopField = $durationField.closest('form').find('[name*=stop]')
  $stopField.val moment($startField.val(), moment.ISO_8601).add(hourglass.Utils.parseDuration $durationField.val()).format()
  hourglass.FormValidator.validateField $stopField

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
  hourglass.FormValidator.validateField $projectField if event.type is 'changefromissue'
  updateActivityField $activityField, $projectField

issueFieldChanged = ->
  $issueTextField = $(@)
  $issueTextField.next().val('') if $issueTextField.val() is ''

split = (timeLogId, mSplitAt, insertNewBefore, round) ->
  $.ajax
    url: hourglassRoutes.split_hourglass_time_log timeLogId
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
      hourglass.Utils.showErrorMessage responseJSON.message
  if startJqXhr
    startJqXhr.fail ({responseJSON}) ->
      hourglass.Utils.showErrorMessage responseJSON.message

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
  .on 'formfieldchanged', '.js-duration', durationFieldChanged
  .on 'submit ajax:before', '.js-validate-form', (event) ->
    isFormValid = hourglass.FormValidator.validateForm $(@)
    unless isFormValid
      event.preventDefault()
      event.stopPropagation()
    return isFormValid
  .on 'ajax:before', '.js-check-splitting', checkSplitting
