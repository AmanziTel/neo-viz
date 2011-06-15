require File.expand_path('../spec_helper', __FILE__)

describe NeoViz do

  def app
    NeoViz::App
  end

  specify "get / should return OK" do
    get '/'
    last_response.should be_ok
  end

  specify 'get /node-count should return number of nodes' do
    get '/node-count'
    last_response.body.should == '155'
  end

  context 'get /nodes/0' do
    before do
      get '/nodes/0'
    end

    let(:body) { last_response.body }

    it 'should return the root node' do
      body.should struct_match({
        :nodes => [
          { :id => 0, :data => {} },
          { :id => 5, :data => {} },
          { :id => 1, :data => {} },
          { :id => 2, :data => {} },
          { :id => 6, :data => {} },
          { :id => 4, :data => {} },
          { :id => 3, :data => {} }
        ],
        :rels => [
          {:id => 4, :start_node => 0, :end_node => 5, :data => { :rel_type => 'BirdiesBackend::User'}},
          {},
          {},
          {},
          {},
          {:id => 2, :start_node => 0, :end_node => 3, :data => { :rel_type => 'BirdiesBackend::Tag'}}
        ]
      })
    end
  end
end
