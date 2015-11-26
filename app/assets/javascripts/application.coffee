#= require jsroutes.js.erb
#= require time_tracker_form
#= require timer

@chronos = {} unless @chronos?
@chronos.ajax = (args) ->
  args.data += '&key=589d212f109c98a0977762fc79c466bbc9c647e0'
  $.ajax args
