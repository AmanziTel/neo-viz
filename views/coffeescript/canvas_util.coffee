root = exports ? window

root.CanvasUtil =
  centerToEdge: (val, delta) ->
    val - delta/2

  roundRect: (ctx, point, width, height, color, radius=5) ->
    x = @centerToEdge(point.x, width)
    y = @centerToEdge(point.y, height)
    ctx.beginPath()
    ctx.moveTo(x + radius, y)
    ctx.fillStyle = @createGradient(ctx, color, y, height)
    ctx.lineTo(x + width - radius, y)
    ctx.quadraticCurveTo(x + width, y, x + width, y + radius)
    ctx.lineTo(x + width, y + height - radius)
    ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height)
    ctx.lineTo(x + radius, y + height)
    ctx.quadraticCurveTo(x, y + height, x, y + height - radius)
    ctx.lineTo(x, y + radius)
    ctx.quadraticCurveTo(x, y, x + radius, y)
    ctx.closePath()
    ctx.fill()

  line: (ctx, fromPoint, toPoint, width = 2) ->
    ctx.lineWidth = width
    ctx.beginPath()
    ctx.moveTo fromPoint.x, fromPoint.y
    ctx.lineTo toPoint.x, toPoint.y
    @arrow(ctx, fromPoint, toPoint, width)
    ctx.stroke()

  arrow: (ctx, fromPoint, toPoint, width = 2) ->
    ctx.save()
    mx = (toPoint.x + fromPoint.x) / 2
    my = (toPoint.y + fromPoint.y) / 2

    ctx.translate(mx, my)
    # draw your arrow, with its origin at [0, 0]
    angle = Math.atan2(toPoint.y-fromPoint.y, toPoint.x-fromPoint.x)
    ctx.rotate(angle)
    arrowSize = 6
    ctx.moveTo(0, 0)
    ctx.lineTo(arrowSize, arrowSize)
    ctx.moveTo(0, 0)
    ctx.lineTo(arrowSize, -arrowSize)
    ctx.restore()
    
  textSize: (ctx, text) ->
    lineHeight = ctx.measureText(text[0]).height or 16
    width = 0
    count = text.length
    height = count * lineHeight + 20
    for line in text
      width = Math.max ctx.measureText(line).width, width
    {width, height, count, lineHeight }

  drawText: (ctx, text, left, top) ->
    textSize = @textSize(ctx, text)
    for i in [0...textSize.count]
      line = text[i]
      ctx.fillText(line, left, top + i*textSize.lineHeight)
  
  createGradient: (ctx, color, y, height) ->
    gradient = ctx.createLinearGradient(0, y, 0, y+height+40)
    gradient.addColorStop(0, color)
    gradient.addColorStop(1, "white")
    gradient 

