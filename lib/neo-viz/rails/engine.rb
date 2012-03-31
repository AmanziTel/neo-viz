module Neo::Viz
  module Rails
    # sets asset pipeline
    # http://guides.rubyonrails.org/asset_pipeline.html#adding-assets-to-your-gems
    class Engine < ::Rails::Engine
      isolate_namespace Neo::Viz
    end
  end
end
