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
  $issueTextField = $timeTrackerControl.find('#issue_text')
  $projectField = $timeTrackerControl.find('#time_tracker_project_id')
  $activityField = $timeTrackerControl.find('#time_tracker_activity_id')
  $startField = $timeTrackerControl.find('#time_tracker_start')

#  chronos.FormValidator.validateForm $timeTrackerControl.find('form')

  $timeTrackerControl.on 'change', (e) ->
    data = {}
    $target = $(e.target)
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
