updateTimeTrackerControlForm = (data) ->
  chronos.Utils.clearFlash()
  $.ajax
    url: chronosRoutes.chronos_time_tracker('current')
    type: 'put'
    data: data
    error: ({responseJSON}) ->
      chronos.Utils.showErrorMessage responseJSON.message

$ ->
  $timeTrackerControl = $('.time-tracker-control')

  ############## edit form ##############
  $timeTrackerEditForm = $timeTrackerControl.find('.edit_time_tracker')
  $issueTextField = $timeTrackerEditForm.find('#issue_text')
  $projectField = $timeTrackerEditForm.find('#time_tracker_project_id')
  $activityField = $timeTrackerEditForm.find('#time_tracker_activity_id')
  $startField = $timeTrackerEditForm.find('#time_tracker_start')

  chronos.FormValidator.validateForm $timeTrackerEditForm

  $timeTrackerEditForm.on 'change', (event) ->
    data = {}
    $target = $(event.target)
    $target = $target.next() if $target.hasClass('js-linked-with-hidden')
    data[$target.attr('name')] = $target.val()
    updateTimeTrackerControlForm data
    chronos.FormValidator.validateField $target

  $issueTextField.on 'change', ->
    $this = $(@)
    $this.next().val('') if $this.val() is ''

  $projectField.on 'change', ->
    $issueTextField.val('').trigger('change') unless $issueTextField.val() is ''
    chronos.Utils.updateActivityField $activityField

  $startField.on 'change', ->
    chronos.Timer.start()

  ############## new form stuff ##############
  $timeTrackerNewForm = $timeTrackerControl.find('.new_time_tracker')
  $taskField = $timeTrackerNewForm.find('#task')

  $taskField.on 'change', ->
    $this = $(@)
    $this.next().val('') if $this.val() is ''

