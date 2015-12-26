$ ->
  $issueActionList = $('#content .contextual')
  $issueActionsToAdd = $('.js-issue-action')
  $issueActionList.first().add($issueActionList.last()).find('a').eq(1).after $issueActionsToAdd.clone().removeClass('hidden')
  $issueActionsToAdd.remove()

