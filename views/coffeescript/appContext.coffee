$ = jQuery

class AppContext

  constructor: (eventBroker)->
    @eventBroker = eventBroker
    @nodeFilter = ''
    @keyFilter = ''
    @nodeCount = 10
    @selectedNode = null

  setNodeCount: (n) ->
    if (@nodeCount != n)
      @nodeCount = n
      @publish("nodeCountChanged")

  getNodeCount: () ->
    @nodeCount

  setKeyFilter: (keyFilter) ->
    if (@keyFilter != keyFilter)
      @keyFilter = keyFilter
      @publish("keyFilterChanged")

#    if keyFilterString?.trim() is ''
#      @keyFilter = null
#    else
#      string = "_neo_id, #{keyFilterString}"
#      @keyFilter = (new RegExp(key.trim()) for key in string.split(','))


  getKeyFilter: ->
    @keyFilter

  setNodeFilter: (filter) ->
    if (@nodeFilter != filter)
      @nodeFilter = filter
      @publish("nodeFilterChanged")

    #@filter = if filter then new RegExp(filter, 'i') else null

  getNodeFilter: ->
    @nodeFilter

  setSelectedNode: (node) ->
    if (@selectedNode != node)
      @selectedNode = node
      @publish("selectedNodeChanged")

  getSelectedNode: ->
    @selectedNode

  # TODO: How do we make this a private method?
  publish: (eventName) ->
    @eventBroker.publish(eventName)

$ ->
  root = exports ? this
  root.appContext = new AppContext(root.eventBroker)

