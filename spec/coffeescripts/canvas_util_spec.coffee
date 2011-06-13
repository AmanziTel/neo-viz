console.log __dirname
util = require('../../views/coffeescript/canvas_util').CanvasUtil

console.log util
describe 'canvas_util', ->
  describe '#centerToEdge', ->
    it 'calculates the edge from the center', ->
      expect(util.centerToEdge(200, 30)).toEqual 185

