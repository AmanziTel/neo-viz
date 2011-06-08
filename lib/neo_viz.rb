require 'sinatra/base'

require 'haml'
require 'barista'
require 'neo4j'


module NeoViz
  class App < Sinatra::Base


    configure do
      register Barista::Integration::Sinatra
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


    get '/node-count' do
      "Number of nodes before index: #{Neo4j.management.get_number_of_node_ids_in_use}"
    end

    get '/root' do
      Neo4j.ref_node.inspect
    end

    get '/tree' do
      Neo4j.ref_node.rels.map { |rel| rel.end_node.attributes }.inspect
    end

    get '/nodes' do
      node_to_hash(Neo4j.ref_node, 1).to_json
    end

    get '/nodes/:id' do |id|
      node = Neo4j::Node._load(id)
      node_to_hash(node, 1).to_json
    end

    get '/env' do
      p request.env
      request.env.inspect
    end

    private
    def node_to_hash(node, depth=1)
      node_hash = only_node(node)
      return node_hash if depth == 0
      rels = node._rels.map do |rel|
        relation(node, rel, depth-1)
      end
      node_hash[:rels] = rels
      node_hash
    end

    def only_node(node) 
      node.props
    end

    def relation(node, rel, depth)
      p rel
      rel.props.merge(:rel_type => rel.rel_type,
                      :direction => (node == rel._end_node ? :incoming : :outgoing),
                      :end_node => node_to_hash(rel._other_node(node), depth))
    end
  end

end
