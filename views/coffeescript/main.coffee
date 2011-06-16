$ = jQuery

Renderer = (canvas, handler) ->
  util = CanvasUtil
  canvas = $(canvas).get(0)
  ctx = canvas.getContext '2d'
  particleSystem = null
  objectHandler = handler
  preferredKeys = [/name/i, /type/i]
  view = null

  init: (system) ->
    particleSystem = system
    particleSystem.screenSize(canvas.width, canvas.height)
    particleSystem.screenPadding(80)
    @initMouseHandling()
    view = @defaultView

  defaultView: (data) ->
    text = []
    usedKeys = {first: true} 
    for regex in preferredKeys
      for key, value of data
        if key.match(regex)
          usedKeys[key] = true
          text.push "#{value} (#{key})"
    for key, value of data
      text.push "#{value} (#{key})" unless usedKeys[key]
    text = text[0..10]
    line[0..28] for line in text

  setView: (newView) ->
    view = newView

  redraw: ->
    ctx.fillStyle = 'white'
    ctx.fillRect 0, 0, canvas.width, canvas.height
    
    particleSystem.eachEdge (edge, fromPoint, toPoint) =>
      @drawEdge(edge, fromPoint, toPoint)

    particleSystem.eachNode (node, point) =>
      @drawNode(node, point)

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
    
    x = (fromPoint.x + toPoint.x) / 2 - 40
    y = (fromPoint.y + toPoint.y) / 2 - 10
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

  addData: (data) ->
    @clear()
    @addNodes data.nodes
    @addRels data.rels

  clear: ->
    for key, node of @nodes
      @sys.pruneNode(key)
    @nodes = {}
    @edges = {}


  addNodes: (nodes) ->
    nodes = nodes[0...10] if nodes.length > 10
    nodes[0].data.first = true
    console.log nodes.length
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

$ ->

  sys = arbor.ParticleSystem(1000, 600, 0.5) # create the system with sensible repulsion/stiffness/friction
  sys.parameters({gravity:true}) # use center-gravity to make the graph settle nicely (ymmv)

  space = new Space(sys)
 
  
  showDetails = (id=0) =>
    node = space.node(id)
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

  getData() 
