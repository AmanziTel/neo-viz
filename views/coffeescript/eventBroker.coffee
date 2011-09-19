$ = jQuery

class EventBroker

  publish: (eventName) ->
    $("body").trigger(eventName)
    console.log 'published ' + eventName

  subscribe: (eventName, func) ->
    $("body").bind(eventName, () ->
      func()
    )

$ ->
  root = exports ? this
  root.eventBroker = new EventBroker
