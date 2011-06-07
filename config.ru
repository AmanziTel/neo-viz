$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
require 'bundler'
Bundler.require

require 'neo-viz'
run NeoViz::App

