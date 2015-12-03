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

projectFieldChanged = (event) ->
  $projectField = $(@)
  $form = $projectField.closest('form')
  $issueTextField = $form.find('.js-issue-autocompletion')
  $activityField = $form.find('[name*=activity_id]')
  $issueTextField.val('').trigger('change') unless $issueTextField.val() is '' or event.type is 'changefromissue'
  updateActivityField $activityField, $projectField

issueFieldChanged = ->
  $issueTextField = $(@)
  $issueTextField.next().val('') if $issueTextField.val() is ''

split = (timeLogId, mSplitAt) ->
  $.ajax
    url: chronosRoutes.split_chronos_time_log timeLogId
    method: 'post'
    data:
      split_at: mSplitAt.toJSON()

checkSplitting = ->
  $form = $(@)
  timeLogId = $form.closest('tr').attr('id')
  $startField = $form.find('[name*=start]')
  $stopField = $form.find('[name*=stop]')
  mStart = moment $startField.val()
  mStartLimit = $startField.data('mLimit')
  mStop = moment $stopField.val()
  mStopLimit = $stopField.data('mLimit')
  stopJqXhr = if mStop.isBefore mStopLimit
    split timeLogId, mStop
  startJqXhr = if mStart.isAfter mStartLimit
    if stopJqXhr
      dfd = jQuery.Deferred()
      stopJqXhr.done ->
        split(timeLogId, mStart)
        .done (response) ->
          dfd.resolve response
        .fail (xhr) ->
          dfd.reject xhr
      dfd
    else
      split timeLogId, mStart

  if startJqXhr and stopJqXhr
    startJqXhr.done ({new_time_log}) ->
      $form
        .attr('action', chronosRoutes.book_chronos_time_log new_time_log.id)
        .removeClass('js-check-splitting')
        .submit()
  else if startJqXhr
    startJqXhr.done ({new_time_log}) ->
      $form
        .attr('action', chronosRoutes.book_chronos_time_log new_time_log.id)
        .removeClass('js-check-splitting')
        .submit()
  else if stopJqXhr
    stopJqXhr.done ->
      $form
        .removeClass('js-check-splitting')
        .submit()

  return not (startJqXhr or stopJqXhr)
$ ->
  $(document)
  .on 'focus', '.js-issue-autocompletion:not(.ui-autocomplete-input)', initIssueAutoCompletion
  .on 'change', '.js-validate-form', formFieldChanged
  .on 'change changefromissue', '[name*=project_id]', projectFieldChanged
  .on 'change', '.js-issue-autocompletion', issueFieldChanged
  .on 'submit', '.js-validate-form', (event) ->
    event.preventDefault() unless chronos.FormValidator.validateForm $(@)
  .on 'ajax:before', '.js-check-splitting', checkSplitting
  .on 'ajax:success', '.js-chronos-remote', ->
    location.reload()
  .on 'ajax:error', '.js-chronos-remote', (event, {responseJSON}) ->
    chronos.Utils.showErrorMessage responseJSON.message
