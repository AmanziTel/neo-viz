require 'sinatra/base'

require 'haml'
require 'sass'
require 'coffee-script'
require 'neo4j'
require 'sprockets'
require 'execjs'

module Neo; module Viz; end; end


module Neo::Viz

  def self.install_path
    return File.expand_path('../..', __FILE__)
  end

  class App < Sinatra::Base

    include Neo4j

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
      @assets_url_prefix = ''
      haml :index
    end

    # Consumers of /embedded have to redefine this method inside
    # the Sprockets environment. See config.ru.
    def root_url
      '.'
    end

    get '/embedded' do
      @assets_url_prefix = request.env["rack.mount.prefix"] || ''
      haml :embedded
    end

    get '/node-count' do
      Neo4j.management.get_number_of_node_ids_in_use.to_s
    end

    get '/tree' do
      Neo4j.ref_node.rels.map { |rel| rel.end_node.attributes }.inspect
    end

    get '/env' do
      #p ExecJS::runtime
      p request.env
      request.env.inspect
    end

    get '/run-specs' do
      haml :jasmine_specs_runner
    end

    get '/eval' do 
      code = params[:code]
      p code
      ret = eval_code code, depth
      if node_data?(ret)
        ret.to_json
      else
        # Hallberg: is seems 'to_s' does not alias 'inspect' for Hash and Array
        # on JRuby 1.6.4 on Windows. Instead {:foo => :bar}.to_s = "foobar"
        # So special case them here.
        if ret.kind_of?(Hash) || ret.kind_of?(Array)
          { :result => ret.inspect}.to_json
        else
          { :result => "#{ret}" }.to_json
        end
      end
    end


    private

    def node_data?(ret)
      ret.kind_of?(Hash) && ret.length == 2 && ret.key?(:nodes) && ret.key?(:rels)
    end

    def depth
      params[:depth].try(:to_i) || 1
    end

    def eval_code(code, depth)
      code = underscore code

      begin
        $Depth = depth
        tx = Neo4j::Transaction.new
        begin
          result = eval <<-EOT
            #{code}
          EOT
        rescue SyntaxError => e
          return e
        end
        tx.success
        result
      rescue => e
        e
      ensure
        tx.finish
      end

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
      data = { :nodes => [], :rels => [] }
      args.each do |arg|
        data_for(data, arg, depth)
      end
      data
    end

    def data_for(data, obj, depth)
      if obj.class.to_s == 'Neo4j::Relationship'
        populate_data(data, arg.start_node, depth, [])
      elsif obj.class.to_s == 'Neo4j::Node'
        populate_data(data, obj, depth, [])
      elsif obj.respond_to? :each
        obj.each do |o|
          data_for(data, o, depth)
        end
      end
      data
    end

    def populate_data(data, node, depth, navigatedRels)
      data[:nodes] << node_data(node)
      return if depth == 0
      node._rels.each do |rel|
        # Make sure we don't walk the same rel path more than once
        if !navigatedRels.include?(rel)
          data[:rels] << rel_data(rel)
          navigatedRels << rel
          populate_data(data, rel._other_node(node), depth-1, navigatedRels)
        end
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
