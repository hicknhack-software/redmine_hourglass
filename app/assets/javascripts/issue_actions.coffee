startNewTracker = ->
  $('.js-start-tracker').off('click.show-start-dialog').first().click()

timeTrackerAjax = (args) ->
  $.ajax
    url: args.url
    type: 'post'
    data: $.extend {_method: args.method}, args.data or {}
    success: args.success
    error: ({responseJSON}) ->
      chronos.Utils.showErrorMessage responseJSON.message

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
        method: 'put'
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
      $('<div/>', class: 'js-start-dialog', title: $startDialogContent.data('dialog-title'))
      .append $startDialogContent.removeClass('hidden')
      .appendTo 'body'
      .dialog(
        autoOpen: true
        resizable: false
        draggable: false
        modal: true
        width: 300
        buttons: [
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
      )
  else
    e.preventDefault()
    e.stopPropagation()
    $startDialog.dialog 'open'

$ ->
  $issueActionList = $('#content .contextual')
  $issueActionsToAdd = $('.js-issue-action')
  $issueActionsToAdd.on 'click.show-start-dialog', showStartDialog if $issueActionsToAdd.hasClass('js-start-tracker')
  $issueActionList.first().add($issueActionList.last()).find('a').eq(1).after $issueActionsToAdd.removeClass('hidden')
