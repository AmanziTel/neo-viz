$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
$LOAD_PATH.unshift File.dirname(__FILE__) + '/views'

require 'sprockets'
require 'neo-viz'
require 'find'

map '/' do
  run Neo::Viz::App
end

map '/assets' do
  environment = Sprockets::Environment.new

  # map all dirs under /public to /assets
  Find.find(File.join(Neo::Viz.install_path, "public")) do |path|
    environment.append_path(path) if FileTest.directory?(path)
  end

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