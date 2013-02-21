module.exports = (ng) ->

  # see https://groups.google.com/forum/#!topic/angular/xZptsb-NYc4
  # and http://plnkr.co/edit/FFBhPIRuT0NA2DZhtoAD
  # needs jquery-ui (yuck, huge!), or at least the effects + highlight plug-ins
  ng.directive 'highlightOnChange', ->
    link: (scope, elem, attrs) ->
      attrs.$observe 'highlightOnChange', ->
        elem.effect? 'highlight'
