describe 'canvas_util', ->
  describe '#centerToEdge', ->
    it 'calculates the edge from the center', ->
      expect(CanvasUtil.centerToEdge(200, 30)).toEqual 185