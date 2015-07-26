module Inesita
  module Server
    SOURCE_MAP_PREFIX = '/__OPAL_MAPS__'

    module_function

    def assets
      Sprockets::Environment.new.tap do |s|
        # register engines
        s.register_engine '.slim', Slim::Template
        s.register_engine '.rb', Opal::Processor

        # add folders
        s.append_path 'app'

        # add paths from opal
        Opal.paths.each do |p|
          s.append_path p
        end

        # add paths from rails-assets
        RailsAssets.load_paths.each do |p|
          s.append_path p
        end

        s.context_class.class_eval do
          def asset_path(path, options = {})
            "#{path}"
          end
        end
      end
    end

    def set_global_vars(assets, debug = false)
      $LOAD_ASSETS_CODE = Opal::Processor.load_asset_code(assets, 'application.js')
      if debug
        $SCRIPT_FILES = (assets['application.js'].dependencies + [assets['application.self.js']]).map(&:logical_path)
      end
    end

    def source_maps(sprockets)
      ::Opal::Sprockets::SourceMapHeaderPatch.inject!(SOURCE_MAP_PREFIX)
      Opal::SourceMapServer.new(sprockets, SOURCE_MAP_PREFIX)
    end

    def create
      assets_app = assets
      source_maps_app = source_maps(assets_app)
      set_global_vars(assets_app, true)

      Rack::Builder.new do
        map '/' do
          run assets_app
        end

        map SOURCE_MAP_PREFIX do
          run source_maps_app
        end
      end
    end
  end
end
