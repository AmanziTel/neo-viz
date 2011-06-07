require 'sinatra/base'
require 'bundler'
Bundler.require

module NeoViz
  class App < Sinatra::Base
    configure(:development) do
      require 'sinatra/reloader'
      register Sinatra::Reloader
      also_reload "lib/**/*.rb"
    end

    get '/env' do
      p request.env
      request.env.inspect
    end
  end
end
