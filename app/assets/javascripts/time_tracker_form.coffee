valueTarget = ($target) ->
  if $target.get(0).type is 'checkbox' and not $target.prop('checked')
    $target.prev()
  else
    $target

formData = {}
putData = {}
putTimer = 0

updateLink = ($field) ->
  $link = $field.closest('.form-field').find('label + a')
  if $link.length
    $link.toggleClass 'hidden', $field.val() is ''
    $link.attr('href', $link.attr('href').replace(/\/([^/]*)$/, "/#{$field.val()}"))

refreshForm = () ->
  $.ajax
    url: hourglassRoutes.hourglass_time_tracker('current')
    type: 'get'
    success: (data) ->
      oldData = formData
      formData = data
      if oldData.issue_id != data.issue_id
        $issueField = $('#time_tracker_issue_id')
        $issueField.val(data.issue_id)
        updateLink($issueField)
      if oldData.project_id != data.project_id
        $projectField = $('#time_tracker_project_id')
        $projectField.val(data.project_id)
        updateLink($projectField)
      if oldData.activity_id != data.activity_id
        $activityField = $('#time_tracker_activity_id')
        $activityField.val(data.activity_id)
      return
    error: ({responseJSON}) ->
      hourglass.Utils.showErrorMessage responseJSON.message

putForm = () ->
  putTimer = 0
  data = putData
  putData = {}
  hourglass.Utils.clearFlash()
  $.ajax
    url: hourglassRoutes.hourglass_time_tracker('current')
    type: 'put'
    data: data
    success: () ->
      refreshForm()
    error: ({responseJSON}) ->
      hourglass.Utils.showErrorMessage responseJSON.message

formFieldChanged = (event) ->
  $target = $(event.target)
  attribute = $target.attr('name')
  key = attribute.replace(/^\w+\[(\w+)\]$/, '$1')
  value = valueTarget($target).val()
  return if value == formData[key]?.toString() or value == putData[attribute]
  putData[attribute] = value
  if attribute.indexOf('project_id') > -1
    $issueField = $(@).find('.js-issue-autocompletion').next()
    putData[$issueField.attr('name')] = $issueField.val()
  unless $target.hasClass('invalid') || putTimer != 0
    putTimer = setTimeout(putForm, 1);

$ ->
  $timeTrackerControl = $('.time-tracker-control')
  hourglass.Timer.start() if $timeTrackerControl.length > 0
  $timeTrackerEditForm = $timeTrackerControl.find('.edit-time-tracker-form')
  $timeTrackerNewForm = $timeTrackerControl.find('.new-time-tracker-form')
  hourglass.FormValidator.validateForm $timeTrackerEditForm

  $timeTrackerEditForm.on 'formfieldchanged', formFieldChanged
  .find('#time_tracker_start')
  .on 'change', ->
    hourglass.Timer.start()

  $timeTrackerEditForm.find('.js-stop-new').on 'click', ->
    $timeTrackerEditForm.data('start-new', true)

  $timeTrackerEditForm.on 'ajax:success', (event) ->
    if $timeTrackerEditForm.data('start-new')
      event.stopPropagation()
      $timeTrackerEditForm.data('start-new', false)
      $.ajax
        url: hourglassRoutes.start_hourglass_time_trackers()
        type: 'post'
        complete: () ->
          location.reload()

  $timeTrackerNewForm.on 'submit', ->
    value = if $('#time_tracker_issue_id').val()
      ''
    else
      $('#time_tracker_task').val()
    $('#time_tracker_comments').val value
