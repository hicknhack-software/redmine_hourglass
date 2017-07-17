@hourglass ?= {}
@hourglass.timeField =
  setValue: ($field, mValue) ->
    $field.val(mValue.toISOString()).change()
    $field.prev().val mValue.utcOffset(window.hourglass.UtcOffset).format(window.hourglass.DateTimeFormat)

$ ->
  $(document)
    .on 'change', '.js-time-field', () ->
      $field = $(@)
      $field.next().val(moment("#{$field.val()} #{window.hourglass.UtcOffset}",
        "#{window.hourglass.DateTimeFormat} ZZ").toISOString()).change()
