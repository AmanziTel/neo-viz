# We set the order of jasmine manually (todo: delegate to sprockets file in that folder)

#= require ./lib/jasmine-1.1.0/jasmine
#= require ./lib/jasmine-1.1.0/jasmine-html

#= require_tree ./lib/
#= require canvas_util
#= require event_broker
#= require neo4j
#= require app_context
#= require filters

#= require renderer
#= require space

$ = jQuery

initFormListeners= (space, renderer, evalCode) ->
  $('#loadForm').submit  (e) ->
    e.preventDefault()
    console.log 'load'
    evalCode()

showNodeDetails = (space, id=0) =>
  node = space.node(id)
  return unless node
  showDetails(node.data)

showDetails = (data) =>
  html = for key, value of data
    if key is 'first' then '' else "<tr><td>#{key}</td><td>#{value}</td></tr>"
  $('#details').empty().append(html.join('\n'))

showEdgeDetails = (space, id=0) =>
  edge = space.rel(id)
  return unless edge
  showDetails(edge.data)


initEventSubscribers = (eventBroker, appContext, space, renderer, getData) ->
  eventBroker.subscribe('nodeCountChanged', ->
    space.setNodeCount appContext.getNodeCount()
  )

  eventBroker.subscribe('nodeFilterChanged', ->
    space.setFilter appContext.getNodeFilter()
  )

  eventBroker.subscribe('keyFilterChanged', ->
    renderer.setKeyFilter appContext.getKeyFilter()
  )

  eventBroker.subscribe('nodeDataChanged', ->
     appContext.clearHiddenNodeData()
     nodeData = appContext.getNodeData()
     space.addData nodeData
     if nodeData.nodes.length > 0
        firstNode = nodeData.nodes[0]
        appContext.setActivatedNodeId(firstNode.id)
        appContext.setSelectedObject(firstNode.id, "node")
  )

  eventBroker.subscribe('hiddenNodeDataChanged', ->
     space.setHiddenData appContext.getHiddenNodeData()
  )

  eventBroker.subscribe('activatedNodeIdChanged', ->
     getData appContext.getActivatedNodeId()
  )

  eventBroker.subscribe('selectedObjectChanged', ->
     object = appContext.getSelectedObject()
     if (object.kind == "node")
        showNodeDetails(space, object.id)
     else
        showEdgeDetails(space, object.id)

  )

  eventBroker.subscribe('refresh', ->
    space.refresh()
  )

$ ->

  $('#consoleOutput').hide()

  sys = arbor.ParticleSystem(1000, 600, 0.5) # create the system with sensible repulsion/stiffness/friction
  sys.parameters({gravity:true}) # use center-gravity to make the graph settle nicely (ymmv)

  space = new Space(sys, @appContext.getNodeCount())

  appendToConsole = (text) ->
      $('#console').val($('#console').val()+ '\n#' + text)

  setError = (text) ->
      $('#consoleOutputArea').val(text)

  getData = (id=0) =>
    depth = $('#depth').val()
    code = if id is 0 then "node = Neo4j.ref_node" else "node = Node._load(#{id})"
    code += "; viz node"
    innerEvalCode(code, depth)

  evalCode = =>
    code = $('#console').val()
    depth = $('#depth').val()
    innerEvalCode(code, depth)

  innerEvalCode = (code, depth) =>
    appContext = @appContext
    console.log code
    $('#eval').attr('disabled', 'true')
    $('#ajax-loader').show()
    # todo: allow dynamic mount point through named path.
#    $.getJSON "<%#= root_url %>/eval", {code: code, depth: depth}, (data) ->
    $.getJSON "/neo-viz/eval", {code: code, depth: depth}, (data) ->
      $('#ajax-loader').hide()
      $('#eval').removeAttr('disabled')
      if data.result
        $('#consoleOutput').show()
        setError data.result
      else
        setError ""
        $('#consoleOutput').hide()
        appContext.setNodeData data

  activateNode = (id=0) =>
    @appContext.setActivatedNodeId(id)

  selectNode = (id=0) =>
    @appContext.setSelectedObject(id, "node")

  selectEdge = (id=0) =>
    @appContext.setSelectedObject(id, "edge")

  objectHandler =
    activated: activateNode
    selectedNode: selectNode
    selectedEdge: selectEdge

  sys.renderer = Renderer("#viewport", objectHandler)

  initFormListeners(space, sys.renderer, evalCode)
  initEventSubscribers(@eventBroker, @appContext, space, sys.renderer, getData)
  activateNode(0)