valueTarget = ($target) ->
  if $target.get(0).type is 'checkbox' and not $target.prop('checked')
    $target.prev()
  else
    $target

formFieldChanged = (event) ->
  data = {}
  $target = $(event.target)
  attribute = $target.attr('name')
  data[attribute] = valueTarget($target).val()
  if attribute.indexOf('project_id') > -1
    $issueField = $(@).find('.js-issue-autocompletion').next()
    data[$issueField.attr('name')] = $issueField.val()
  unless $target.hasClass('invalid')
    hourglass.Utils.clearFlash()
    $.ajax
      url: hourglassRoutes.hourglass_time_tracker('current')
      type: 'put'
      data: data
      error: ({responseJSON}) ->
        hourglass.Utils.showErrorMessage responseJSON.message

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
