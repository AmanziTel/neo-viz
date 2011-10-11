//= require "sylvester.js"

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
    # If keyfilter is active then show all properties ("keys") passing the filter.
    # Otherwise only show 3 props but indicate how many there really are.
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

      nbrProps = text.length - 1 # -1 since we don't count _neo_id
      nbrPropsToShow = 3
      addEllipsis = nbrProps - nbrPropsToShow > 0
      text = text[0..nbrPropsToShow]
      text.push "(#{nbrProps-nbrPropsToShow} more)" if addEllipsis

    line[0..40] for line in text

  setKeyFilter: (keyFilterString) ->
    if keyFilterString?.trim() is ''
      keyFilter = null
    else
      string = "_neo_id, #{keyFilterString}"
      keyFilter = (new RegExp(key.trim()) for key in string.split(','))

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
      maxWidth = 230
      maxHeight = 100
      width = Math.min(width, maxWidth)
      height = Math.min(height, maxHeight)

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

  middle: (p1, p2) ->
    if p1 > p2
      (p1 - p2) / 2 + p2
    else
      (p2 - p1) / 2 + p1


  edgeHitTest: (point, p1, p2, thresholdInPixels) ->
    delta = thresholdInPixels
    mx = @middle(p1.x, p2.x)
    my = @middle(p1.y, p2.y)
    return false if point.x < mx - delta
    return false if point.x > mx + delta
    return false if point.y < my - delta
    return false if point.y > my + delta
    true

  initMouseHandling: ->

    handler =

      dblclick: (e) ->
        pos = $(canvas).offset()
        _mouseP = arbor.Point(e.pageX-pos.left, e.pageY-pos.top)
        object = particleSystem.nearest(_mouseP)
        objectHandler.activated object.node.name
        false

      click: (e) =>
        pos = $(canvas).offset()
        _mouseP = arbor.Point(e.pageX-pos.left, e.pageY-pos.top)

        hitEdge = false
        particleSystem.eachEdge (edge, fromPoint, toPoint) =>
          if (@edgeHitTest(_mouseP, fromPoint, toPoint, 14))
            objectHandler.selectedEdge edge.data._neo_id
            hitEdge = true
            return false

        if !hitEdge
          object = particleSystem.nearest(_mouseP)
          objectHandler.selectedNode(object.node.name)
        false

    $(canvas)
      .dblclick(handler.dblclick)
      .click(handler.click)


root = exports ? this
root.Renderer = Renderer

