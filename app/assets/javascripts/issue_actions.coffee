startNewTracker = ->
  $('.js-start-tracker').off('click.show-start-dialog').first().click()

timeTrackerAjax = (args) ->
  $.ajax
    url: args.url
    type: args.type || 'post'
    data: $.extend {_method: args.method}, args.data or {}
    success: args.success
    error: ({responseJSON}) ->
      chronos.Utils.showErrorMessage responseJSON.message

stopDialogApplyHandler = (args) ->
  $stopDialog = $(@)
  $stopDialog.dialog 'close'
  timeTrackerAjax
    url: chronosRoutes.chronos_time_tracker 'current'
    type: 'put'
    data:
      time_tracker:
        activity_id: $stopDialog.find('[name*=activity_id]').val()
    success: ->
      $('.js-stop-tracker').off('click.show-stop-dialog').first().click()

startDialogApplyHandler = ->
  $startDialog = $(@)
  $startDialog.dialog 'close'
  switch $startDialog.find('input[type=radio]:checked').val()
    when 'log'
      timeTrackerAjax
        url: chronosRoutes.stop_chronos_time_tracker 'current'
        method: 'delete'
        success: startNewTracker
    when 'discard'
      timeTrackerAjax
        url: chronosRoutes.chronos_time_tracker 'current'
        method: 'delete'
        success: startNewTracker
    when 'takeover'
      timeTrackerAjax
        url: chronosRoutes.chronos_time_tracker 'current'
        type: 'put'
        data: $('.js-start-tracker').data('params')
        success: ->
          location.reload()

showStartDialog = (e) ->
  $startDialog = $('.js-start-dialog')
  if $startDialog.length is 0
    $startDialogContent = $('.js-start-dialog-content')
    if $startDialogContent.length isnt 0
      e.preventDefault()
      e.stopPropagation()
      chronos.Utils.showDialog 'js-start-dialog', $startDialogContent, [
        {
          text: $startDialogContent.data('button-ok-text')
          click: startDialogApplyHandler
        }
        {
          text: $startDialogContent.data('button-cancel-text')
          click: ->
            $(this).dialog 'close'
        }
      ]
  else
    e.preventDefault()
    e.stopPropagation()
    $startDialog.dialog 'open'

showStopDialog = (e) ->
  e.preventDefault()
  $stopDialog = $('.js-stop-dialog')
  if $stopDialog.length is 0
    $stopDialogContent = $('.js-stop-dialog-content')
    if $stopDialogContent.length isnt 0
      e.preventDefault()
      e.stopPropagation()
      chronos.Utils.showDialog 'js-stop-dialog', $stopDialogContent, [
        {
          text: $stopDialogContent.data('button-ok-text')
          click: stopDialogApplyHandler
        }
        {
          text: $stopDialogContent.data('button-cancel-text')
          click: ->
            $(this).dialog 'close'
        }
      ]
  else
    $stopDialog.dialog 'open'

$ ->
  $issueActionList = $('#content .contextual')
  $issueActionsToAdd = $('.js-issue-action')
  $issueActionsToAdd.on 'click.show-start-dialog', showStartDialog if $issueActionsToAdd.hasClass('js-start-tracker')
  $issueActionsToAdd.on 'click.show-stop-dialog', showStopDialog if $issueActionsToAdd.hasClass('js-stop-tracker')
  $issueActionList.first().add($issueActionList.last()).find(':nth-child(2)').after $issueActionsToAdd.removeClass('hidden')
