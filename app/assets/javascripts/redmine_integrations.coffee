startNewTracker = ->
  $('.js-start-tracker').addClass('js-skip-dialog').first().click()

timeTrackerAjax = (args) ->
  $.ajax
    url: args.url
    type: args.type || 'post'
    data: $.extend {_method: args.method}, args.data or {}
    success: args.success
    error: ({responseJSON}) ->
      hourglass.Utils.showErrorMessage responseJSON.message

stopDialogApplyHandler = (args) ->
  $stopDialog = $(@)
  $activityField = $stopDialog.find('[name*=activity_id]')
  return unless hourglass.FormValidator.validateField $activityField
  $stopDialog.dialog 'close'
  timeTrackerAjax
    url: hourglassRoutes.hourglass_time_tracker 'current'
    type: 'put'
    data:
      time_tracker:
        activity_id: $activityField.val()
    success: ->
      $('.js-stop-tracker').addClass('js-skip-dialog').first().click()

startDialogApplyHandler = ->
  $startDialog = $(@)
  $startDialog.dialog 'close'
  switch $startDialog.find('input[type=radio]:checked').val()
    when 'log'
      timeTrackerAjax
        url: hourglassRoutes.stop_hourglass_time_tracker 'current'
        method: 'delete'
        success: startNewTracker
    when 'discard'
      timeTrackerAjax
        url: hourglassRoutes.hourglass_time_tracker 'current'
        method: 'delete'
        success: startNewTracker
    when 'takeover'
      timeTrackerAjax
        url: hourglassRoutes.hourglass_time_tracker 'current'
        type: 'put'
        data: $('.js-start-tracker').data('params')
        success: ->
          location.reload()

showStartDialog = (e) ->
  return true if $(@).hasClass('js-skip-dialog')
  $startDialog = $('.js-start-dialog')
  if $startDialog.length is 0
    $startDialogContent = $('.js-start-dialog-content')
    if $startDialogContent.length isnt 0
      e.preventDefault()
      e.stopPropagation()
      hourglass.Utils.showDialog 'js-start-dialog', $startDialogContent, [
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
  return true if $(@).hasClass('js-skip-dialog')
  $stopDialog = $('.js-stop-dialog')
  if $stopDialog.length is 0
    $stopDialogContent = $('.js-stop-dialog-content')
    if $stopDialogContent.length isnt 0
      e.preventDefault()
      e.stopPropagation()
      hourglass.Utils.showDialog 'js-stop-dialog', $stopDialogContent, [
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
      $stopDialogContent.on 'change', '[name*=activity_id]', ->
        hourglass.FormValidator.validateField $(@)
  else
    e.preventDefault()
    e.stopPropagation()
    $stopDialog.dialog 'open'

window.oldToggleOperator = window.toggleOperator
window.toggleOperator = (field) ->
  operator = $("#operators_" + field.replace('.', '_')).val()
  return enableValues(field, []) if operator is 'q' or operator is 'lq
  window.oldToggleOperator field

$ ->
  $issueActionList = $('#content .contextual')
  $issueActionsToAdd = $('.js-issue-action')
  $issueActionList.first().add($issueActionList.last())
    .find(':nth-child(2)').after $issueActionsToAdd.removeClass('hidden')

  $('.hourglass-quick').replaceWith $('.js-account-menu-link').removeClass('hidden')

  $('#content, #top-menu')
    .on 'click', '.js-start-tracker', showStartDialog
    .on 'click', '.js-stop-tracker', showStopDialog

  $contextMenuTarget = null
  $(document).on 'contextmenu', '.hourglass-list', (e) ->
    $contextMenuTarget = $(@)

  $.ajaxPrefilter (options) ->
    return unless options.url.endsWith 'hourglass/ui/context_menu'
    options.data = $.param list_type: $contextMenuTarget.data('list-type')
    $contextMenuTarget.find('.context-menu-selection').each ->
      options.data += "&ids[]=#{@id}"

