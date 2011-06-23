$LOAD_PATH.unshift File.dirname(__FILE__) + '/..'
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'rack/test'
require 'support/struct_matcher'
require 'neo-viz'


class Neo::Viz::App
  set :environment, :test
end

RSpec.configure do |c|
  c.include Rack::Test::Methods
  c.mock_with :rspec
  c.include Matchers
end
