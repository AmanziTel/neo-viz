require File.expand_path('../spec_helper', __FILE__)

describe NeoViz do

  def app
    NeoViz::App
  end

  specify "get / should return OK" do
    get '/'
    last_response.should be_ok
  end

  specify 'get /node-count should return 200' do
    get '/node-count'
    last_response.body.should == '2912'
  end

  context 'get /nodes/0' do
    before do
      get '/nodes/0'
    end

    let(:body) { last_response.body }

    it 'should return the root node' do
      body.should struct_match({
        :_neo_id =>  0,
        :rels => [
          {:rel_type => 'BirdiesBackend::User', :direction => 'outgoing', :other_node => {}},
          {:rel_type => 'Neo4j::Rails::Model', :direction => 'outgoing', :other_node => {}},
          {:rel_type => 'BirdiesBackend::Link', :direction => 'outgoing', :other_node => {}},
          {:rel_type => 'BirdiesBackend::Tweeters', :direction => 'outgoing', :other_node => {}},
          {:rel_type => 'BirdiesBackend::Tweet', :direction => 'outgoing', :other_node => {}},
          {:rel_type => 'BirdiesBackend::Tag', :direction => 'outgoing', :other_node => {}}
        ]
      })
    end
  end
end
