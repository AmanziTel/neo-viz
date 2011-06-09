## Neo-Viz

Neo-Viz is a tool for visualizing Neo data in the browser. It is
a Sinatra application that uses Neo4j.rb to read data from a Neo
database directory. It shows the data using Javascript in a browser.


### To do

#### Server

* Change the protocol for sending the data to the client.
  Send nodes and relations as JSON arrays.
* Make it possible to choose where that data comes from
* Implement a command line interface for starting the server and
  selecting the data source.
* A query protocol for selecting only the relevant nodes


#### Client

* Connect with the Server to get the data.
* Fetch new data from the Server when a node is selected.
* Limit the amount of nodes shown on the screen.
* Show the properties of the nodes and relations.
* Views for showing only the relevant properties.
* Query protocol editor to select the relevant nodes to ask from the
  server.


