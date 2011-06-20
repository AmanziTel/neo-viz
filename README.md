## Neo-Viz

Neo-Viz is a tool for visualizing Neo data in the browser. It is
a Sinatra application that uses Neo4j.rb to read data from a Neo
database directory. It shows the data using Javascript in a browser.


### To do

#### Server

* Make it possible to choose where that data comes from
* Implement a command line interface for starting the server and
  selecting the data source.


#### Client

* Relationship filter
* Group nodes, if there are too many to show.
* bind and trigger with custom events


### Changes

#### Server

* 2011-06-20 A query protocol for selecting only the relevant nodes
* Change the protocol for sending the data to the client.
  Send nodes and relations as JSON arrays. 

#### Client

* 2011-06-20 Query protocol editor to select the relevant nodes to ask
  from the server.
* 2011-06-16 Views for showing only the relevant properties.
* 2011-06-16 Node filter
* 2011-06-16 Select number of nodes to show.
* 2011-06-14 Click to show detailed information.
* Connect with the Server to get the data.
* Fetch new data from the Server when a node is selected.
* Limit the amount of nodes shown on the screen.
* Show the properties of the nodes and relations.

