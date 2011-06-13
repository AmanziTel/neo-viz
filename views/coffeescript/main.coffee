$ = jQuery

Renderer = (canvas, clickHandler) ->
  util = CanvasUtil
  canvas = $(canvas).get(0)
  ctx = canvas.getContext '2d'
  particleSystem = null
  onClick = clickHandler

  init: (system) ->
    particleSystem = system
    particleSystem.screenSize(canvas.width, canvas.height)
    particleSystem.screenPadding(80)
    @initMouseHandling()
  
  redraw: ->
    ctx.fillStyle = 'white'
    ctx.fillRect 0, 0, canvas.width, canvas.height
    
    particleSystem.eachEdge (edge, fromPoint, toPoint) ->
      ctx.strokeStyle = 'rgba(0,0,0, .333)'
      util.line ctx, fromPoint, toPoint

    particleSystem.eachNode (node, point) ->
      MARGIN = 10

      ctx.font = "12pt Times"
      {width, height, count} = util.textSize ctx, node.data
      width = Math.max(height, 160)
      height = Math.max(height, 60)

      ctx.fillStyle = if node.name is 0 then "blue" else "green"
      util.roundRect(ctx, point, width+(MARGIN*2), height, 10)

      ctx.fillStyle ='white'
      util.drawText(ctx, node.data, util.centerToEdge(point.x, width), 
        util.centerToEdge(point.y, height)+20)
  
  initMouseHandling: ->
    handler =
      clicked: (e) ->
        pos = $(canvas).offset()
        _mouseP = arbor.Point(e.pageX-pos.left, e.pageY-pos.top)
        object = particleSystem.nearest(_mouseP)
        console.log object
        onClick object.node.name
        false
      
    # start listening
    $(canvas).mousedown(handler.clicked)


class Space
  constructor: (@sys) ->
    @nodes = {}
    @rels = {}
    @preferredKeys = [/name/i, /type/i]
    @view = (data) ->
      text = []
      for regex in @preferredKeys
        for key, value of data
          if key.match(regex)
            text.push "#{value} (#{key})"
      if text.length < 1
        for key, value of data
          text.push "#{value} (#{key})"
        text = text[0..1]
      text

  setView: (@view) ->

  addData: (data) ->
    @addNodes data.nodes
    @addRels data.rels

  addNodes: (nodes) ->
    for node in nodes
      @sys.addNode(node.id, @props(node)) unless @nodes[node.id]
      @nodes[node.id] = node

  addRels: (rels) ->
    for rel in rels
      @sys.addEdge(rel.start_node, rel.end_node, @props(rel)) unless @rels[rel.id]
      @rels[rel.id] = rel
  
  props: (obj) ->
    @view(obj.data)



$ ->

    

  sys = arbor.ParticleSystem(1000, 600, 0.5) # create the system with sensible repulsion/stiffness/friction
  sys.parameters({gravity:true}) # use center-gravity to make the graph settle nicely (ymmv)

  space = new Space(sys)
  
  getData = (id=0) =>
    $.getJSON "/nodes/#{id}", (data) ->
      space.addData data


  sys.renderer = Renderer("#viewport", getData) # our newly created renderer will have its .init() method called shortly by sys...

  getData() 

