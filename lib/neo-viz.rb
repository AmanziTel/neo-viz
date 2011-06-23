require 'sinatra/base'

require 'haml'
require 'sass'
require 'coffee-script'
require 'neo4j'

module Neo; module Viz; end; end

module Neo::Viz
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
      redirect to('/index')
    end

    get '/index' do
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
      data_for_node(Neo4j.ref_node, depth).to_json
    end

    get '/nodes/:id' do |id|
      node = Neo4j::Node._load(id)
      data_for_node(node, depth).to_json
    end

    get '/env' do
      p request.env
      request.env.inspect
    end

    get '/eval' do 
      code = params[:code]
      p code
      ret = eval_code code, depth
      if ret.kind_of?(Hash)
        ret.to_json
      else
        { :result => "#{ret}" }.to_json
      end
    end


    private

    def depth
      params[:depth].try(:to_i) || 1
    end

    def eval_code(code, depth)
      code = underscore code
      ret = eval <<-EOT
        begin
          $Depth = #{depth}
          #{code}
        rescue => e
          e
        end
      EOT
    end

    # This changes the code to use the internal versions that
    # don't use classes, but just pure nodes and relations.
    def underscore code
      code.
        gsub(/\bload\b/, '_load').
        gsub(/\brels\b/, '_rels').
        gsub(/\bnode\b/, '_node')
    end

    def viz(*args) 
      depth = $Depth 
      p depth
      data = { :nodes => [], :rels => [] }
      args.each do |arg|
        data_for(data, arg, depth)
      end
      p data
      data
    end

    def data_for(data, obj, depth)
      p obj.class
      if obj.class.to_s == 'Neo4j::Relationship'
        p 'hello'
        populate_data(data, arg.start_node, depth)
      elsif obj.class.to_s == 'Neo4j::Node'
        p obj
        populate_data(data, obj, depth)
      elsif obj.respond_to? :each
        obj.each do |o|
          data_for(data, o, depth)
        end
      end
      data
    end

    def data_for_node(node, depth=1)
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
