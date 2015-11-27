updateTimeTrackerControlForm = (data) ->
  chronos.clearFlash()
  $.ajax
    url: chronosRoutes.chronos_time_tracker('current')
    type: 'put'
    data: data
    error: ({responseJSON}) ->
      chronos.showErrorMessage responseJSON.message

$ ->
  $timeTrackerControl = $('.time-tracker-control')
  $issueTextField = $timeTrackerControl.find('#issue_text')
  $projectSelectField = $timeTrackerControl.find('#project_select')
  $timeTrackerControl.on 'change', (e) ->
    data = {}
    $target = $(e.target)
    $target = $target.next() if $target.hasClass('js-linked-with-hidden')
    data[$target.attr('name')] = $target.val()
    updateTimeTrackerControlForm data

  $issueTextField.on 'change', ->
    $this = $(@)
    $this.next().val('') if $this.val() is ''

  $projectSelectField.on 'change', ->
    $this = $(@)
    $this.next().val $this.val()
    $issueTextField.val('').trigger('change')
