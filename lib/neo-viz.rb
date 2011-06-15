require 'sinatra/base'

require 'haml'
require 'sass'
require 'coffee-script'
require 'neo4j'


module NeoViz
  class App < Sinatra::Base

    configure do
      set :public, File.expand_path('../../public/', __FILE__)
      set :views, File.expand_path('../../views/', __FILE__)
    end

    configure(:development) do
      require 'sinatra/reloader'
      register Sinatra::Reloader
      also_reload "lib/**/*.rb"
    end

    get '/' do
      haml :index
    end

    get '/stylesheets/main.css' do
      scss :'scss/main'
    end

    get '/javascripts/main.js' do
      coffee :'coffeescript/main'
    end

    get '/javascripts/canvas_util.js' do
      coffee :'coffeescript/canvas_util'
    end

    get '/node-count' do
      Neo4j.management.get_number_of_node_ids_in_use.to_s
    end

    get '/tree' do
      Neo4j.ref_node.rels.map { |rel| rel.end_node.attributes }.inspect
    end

    get '/nodes/0' do
      data_for(Neo4j.ref_node, 1).to_json
    end

    get '/nodes/:id' do |id|
      node = Neo4j::Node._load(id)
      data_for(node, 1).to_json
    end

    get '/env' do
      p request.env
      request.env.inspect
    end

    private
    def data_for(node, depth=1)
      data = { :nodes => [], :rels => [] }
      populate_data(data, node, depth) 
      data
    end

    def populate_data(data, node, depth)
      node_hash = node_data(node)
      data[:nodes] << node_data(node)
      return if depth == 0
      node._rels.each do |rel|
        data[:rels] << rel_data(rel)
        populate_data(data, rel._other_node(node), depth-1)
      end
    end

    def node_data(node)
      {
        :id => node.props['_neo_id'],
        :data => node.props,
      }
    end

    def rel_data(rel)
      {
        :id => rel.props['_neo_id'],
        :start_node => rel._start_node.props['_neo_id'],
        :end_node => rel._end_node.props['_neo_id'],
        :data => rel.props.merge(:rel_type => rel.rel_type)
      }
    end
  end

end
