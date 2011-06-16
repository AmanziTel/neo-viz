## Neo-Viz

Neo-Viz is a tool for visualizing Neo data in the browser. It is
a Sinatra application that uses Neo4j.rb to read data from a Neo
database directory. It shows the data using Javascript in a browser.


### To do

#### Server

* Make it possible to choose where that data comes from
* Implement a command line interface for starting the server and
  selecting the data source.
* A query protocol for selecting only the relevant nodes


#### Client

* Relationship filter
* Views for showing only the relevant properties.
* Group nodes, if there are too many to show.
* Query protocol editor to select the relevant nodes to ask from the
  server.
* bind and trigger with custom events


### Changes

#### Server

* Change the protocol for sending the data to the client.
  Send nodes and relations as JSON arrays. 

#### Client

* Node filter
* 2011-06-16 Select number of nodes to show.
* 2011-06-14 Click to show detailed information.
* Connect with the Server to get the data.
* Fetch new data from the Server when a node is selected.
* Limit the amount of nodes shown on the screen.
* Show the properties of the nodes and relations.

