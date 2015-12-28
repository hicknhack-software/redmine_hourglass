okButtonClick = () ->


showStartDialog = (e) ->
  e.preventDefault()
  e.stopPropagation()
  window.contextMenuHide() if $.isFunction window.contextMenuHide

  $startDialog = $('.js-start-dialog')
  if $startDialog.length is 0
    $startDialogContent = $('.js-start-dialog-content')
    if $startDialogContent.length isnt 0
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
            class: 'js-ok-button'
            text: $startDialogContent.data('button-ok-text')
            click: ->
              $(this).dialog 'close'
          }
          {
            text: $startDialogContent.data('button-cancel-text')
            click: ->
              $(this).dialog 'close'
          }
        ]
      )
  else
    $startDialog.dialog 'open'

$ ->
  $issueActionList = $('#content .contextual')
  $issueActionsToAdd = $('.js-issue-action')
  $issueActionsToAdd.on 'click', showStartDialog if $issueActionsToAdd.hasClass('js-start-tracker')
  $issueActionList.first().add($issueActionList.last()).find('a').eq(1).after $issueActionsToAdd.clone(true).removeClass('hidden')
  $issueActionsToAdd.remove()

