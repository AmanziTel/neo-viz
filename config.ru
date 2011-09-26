$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
$LOAD_PATH.unshift File.dirname(__FILE__) + '/views'

require 'sprockets'
require 'neo-viz'

map '/' do
  run Neo::Viz::App
end

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'public/javascripts'
  environment.append_path 'public/lib/jasmine-1.1.0'
  environment.append_path 'views/coffeescript'

  environment.instance_eval do
    @context_class.instance_eval do
      define_method :root_url do
        '.'
      end
    end
  end

  run environment
end

map '/specs' do
  environment = Sprockets::Environment.new
  environment.append_path 'spec/coffeescripts'
  run environment
end