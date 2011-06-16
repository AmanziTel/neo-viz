$ = jQuery

Renderer = (canvas, handler) ->
  util = CanvasUtil
  canvas = $(canvas).get(0)
  ctx = canvas.getContext '2d'
  particleSystem = null
  objectHandler = handler
  view = null
  keyFilter = null

  init: (system) ->
    particleSystem = system
    particleSystem.screenSize(canvas.width, canvas.height)
    particleSystem.screenPadding(80)
    @initMouseHandling()
    view = @defaultView


  defaultView: (data) ->
    text = []
    usedKeys = {first: true} 
    if keyFilter?.length > 0
      for regex in keyFilter
        for key, value of data
          if key.match(regex)
            text.push "#{value} (#{key})" unless usedKeys[key]
            usedKeys[key] = true
    else
      for key, value of data
        text.push "#{value} (#{key})" unless key is 'first'
      text = text[0..10]
    line[0..28] for line in text

  setKeyFilter: (keyFilterString) ->
    if keyFilterString?.trim() is ''
      keyFilter = null 
    else
      string = "_neo_id, #{keyFilterString}"
      keyFilter = (new RegExp(key.trim()) for key in string.split(','))

  redraw: ->
    ctx.fillStyle = 'white'
    ctx.fillRect 0, 0, canvas.width, canvas.height
    
    particleSystem.eachNode (node, point) =>
      @drawNode(node, point)

    particleSystem.eachEdge (edge, fromPoint, toPoint) =>
      @drawEdge(edge, fromPoint, toPoint)

  drawNode: (node, point) ->
      MARGIN = 10
      
      nodeView = view node.data
      ctx.font = "10pt Times"
      {width, height, count} = util.textSize ctx, nodeView
      width = Math.max(height, 160)
      height = Math.max(height, 60)
      
      color = if node.data.first then "blue" else "green"
      util.roundRect(ctx, point, width+(MARGIN*2), height, color, 10)

      ctx.fillStyle ='white'
      x = util.centerToEdge(point.x, width) 
      y = util.centerToEdge(point.y, height) + MARGIN*2
      util.drawText(ctx, nodeView, x, y)

    
  drawEdge: (edge, fromPoint, toPoint) ->
    ctx.strokeStyle = 'rgba(0,0,0, .333)'
    util.line ctx, fromPoint, toPoint
    
    x = (fromPoint.x + toPoint.x) / 2 - 30
    y = (fromPoint.y + toPoint.y) / 2 
    ctx.font = "10pt Times"
    ctx.fillStyle ='red'
    util.drawText(ctx, [edge.data.rel_type], x, y) 
      
  initMouseHandling: ->
    handler =
      dblclick: (e) ->
        pos = $(canvas).offset()
        _mouseP = arbor.Point(e.pageX-pos.left, e.pageY-pos.top)
        object = particleSystem.nearest(_mouseP)
        objectHandler.activated object.node.name
        false
      
      click: (e) ->
        pos = $(canvas).offset()
        _mouseP = arbor.Point(e.pageX-pos.left, e.pageY-pos.top)
        object = particleSystem.nearest(_mouseP)
        objectHandler.selected object.node.name
        false
    $(canvas)
      .dblclick(handler.dblclick)
      .click(handler.click)


class Space
  constructor: (@sys) ->
    @nodes = {}
    @rels = {}
    @nodesToShow = 10

  addData: (data) ->
    @clear()
    @addNodes data.nodes
    @addRels data.rels

  clear: ->
    for key, node of @nodes
      @sys.pruneNode(key)
    @nodes = {}
    @edges = {}

  getSelectedNode: ->
    @selectedNode

  setFilter: (filter) ->
    @filter = if filter then new RegExp(filter, 'i') else null

  setNodesToShow: (n) ->
    @nodesToShow = n

  addNodes: (nodes) ->
    return if nodes.length == 0
    inspect = (node) ->
      name = (for key, value of node.data
        "#{key}:#{value}").join(' ')
      name

    @selectedNode = nodes[0]
    @selectedNode.data.first = true

    nodes = (node for node in nodes when inspect(node).match(@filter)) if @filter
    return if nodes.length is 0
    return if nodes[0] is @selectedNode and nodes.length is 1
    nodes.unshift(@selectedNode)

    nodes = nodes[0...@nodesToShow] if nodes.length > @nodesToShow
    for node in nodes
      @sys.addNode(node.id, node.data) unless @nodes[node.id]
      @nodes[node.id] = node

  addRels: (rels) ->
    for rel in rels
      if @nodes[rel.start_node] and @nodes[rel.end_node]
        @sys.addEdge(rel.start_node, rel.end_node, rel.data)
        @rels[rel.id] = rel
  
  node: (id) ->
    @nodes[id]

initFormListeners= (space, renderer, getData) ->
  $('#node-count').change ->
    space.setNodesToShow $(this).val()
  $('#node-filter').change ->
    space.setFilter $(this).val()
  $('#key-filter').change ->
    renderer.setKeyFilter $(this).val()
  $('form').submit  (e) ->
    e.preventDefault()
    console.log 'submit'
    getData space.getSelectedNode().id


$ ->

  sys = arbor.ParticleSystem(1000, 600, 0.5) # create the system with sensible repulsion/stiffness/friction
  sys.parameters({gravity:true}) # use center-gravity to make the graph settle nicely (ymmv)

  space = new Space(sys)
 
  
  showDetails = (id=0) =>
    node = space.node(id)
    return unless node
    html = for key, value of node.data
      if key is 'first' then '' else "<tr><td>#{key}</td><td>#{value}</td></tr>" 

    $('#details').empty().append(html.join('\n'))

  getData = (id=0) =>
    $.getJSON "./nodes/#{id}", (data) ->
      space.addData data
      showDetails(id)

  objectHandler =
    activated: getData
    selected: showDetails

  sys.renderer = Renderer("#viewport", objectHandler) 

  initFormListeners(space, sys.renderer, getData)

  getData() 
