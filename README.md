# Neo-Viz

Neo-Viz is a tool for visualizing Neo data in the browser. It is
a Sinatra application that uses Neo4j.rb to read data from a Neo
database directory. It shows the data using Javascript in a browser.


## Installing

The visualizer can be used stand-alone or embedded in a Rails application.

### External Dependencies

The visualizer has an external dependency on coffee-script. It can be
installed by:

    # OS X
    $ brew install coffee-script

    # Linux
    $ apt-get install coffee-script



### Standalone

To use it standalone you must first get the code from the repository.

    $ git clone git@github.com:AmanziTel/neo-viz.git
    $ cd neo-viz
    
    # To use it as is
    $ rackup
    [2011-06-23 07:48:34] INFO  WEBrick 1.3.1
    [2011-06-23 07:48:34] INFO  ruby 1.8.7 (2011-05-23) [java]
    [2011-06-23 07:48:34] INFO  WEBrick::HTTPServer#start: pid=64743 port=9292

    
    # To install it as a gem
    $ rake install
    neo-viz 1.0.0 built to pkg/neo-viz-1.0.0.gem
    neo-viz (1.0.0) installed
    
    $ neo-viz
    [2011-06-23 07:51:10] INFO  WEBrick 1.3.1
    [2011-06-23 07:51:10] INFO  ruby 1.8.7 (2011-05-23) [java]
    [2011-06-23 07:51:10] INFO  WEBrick::HTTPServer#start: pid=64864 port=1666
    
### Embedding in Rails

To embed the visualizer in Rails, you first have to add it to your `Gemfile`.
   
    # Gemfile
    gem 'neo-viz', :git => 'git@github.com:AmanziTel/neo-viz.git'

Then you have to mount the route in `routes.rb`

    # config/routes.rb
    mount Neo::Viz::App => '/neo-viz'

You can now access it at e.g. http://localhost:3000/neo-viz.

## Neo4j Database

The standalone version expects a `db` directory containing the usual
Neo4j database files.
    
The embedded version uses the Neo4j database that has been configured
for the embedding project.

## Known issues

There is a problem running the Jasmine specs (/run-specs) on Windows if the "therubyrhino" gem is installed
and you are using JRuby. On Windows we want to use the built-in JScript runtime but ExecJS chooses Rhino if it
is installed.

Typical errors returned over HTTP when requesting a .coffee file:

    throw Error("NativeException: org.mozilla.javascript.JavaScriptException:
        Error: too many ) on line 2 (<eval>#8)\n  (in c:/..../neo-viz/public/coffeescripts/canvas_util.coffee)")

A workaround is to uninstall the therubyrhino gem, but ofcourse it will be re-installed on every call to bundle.
I can't figure out how to tell bundler not to load a specific gem when I'm on JRuby and Windows.

## To do

### Server

* Make it possible to choose where that data comes from
* Implement a command line interface for starting the server and
  selecting the data source.


### Client

* Group nodes, if there are too many to show.
* bind and trigger with custom events



### Changes

* 2011-09-28 Added relationship filter
* 2011-06-23 Changed the namespace.
* 2011-06-23 Added depth to the traversal algorithm
* 2011-06-20 A query protocol for selecting only the relevant nodes
* 2011-06-20 Query protocol editor to select the relevant nodes to ask
* 2011-06-16 Views for showing only the relevant properties.
* 2011-06-16 Node filter
* 2011-06-16 Select number of nodes to show.
* 2011-06-14 Click to show detailed information.
* Connect with the Server to get the data.
* Fetch new data from the Server when a node is selected.
* Limit the amount of nodes shown on the screen.
* Show the properties of the nodes and relations.

