class InesitaCLI < Thor
  include Thor::Actions

  check_unknown_options!

  namespace :build

  desc "build [OPTIONS]", "Build Inesita app"

  method_option :force,
    aliases: ['-f'],
    default: false,
    desc: 'force overwrite'

  method_option :destination,
    aliases: ['-d', '-dir'],
    default: 'public',
    desc: 'build destination directory'

  def build#(destination: build_dir, force:)
    build_dir, force = options[:destination], options[:force]

    assets = Inesita::Server.assets
    Inesita::Server.set_global_vars(assets, false)

    index      = assets['index.html']
    javascript = assets['application.js']
    stylesheet = assets['stylesheet.css']

    empty_directory build_dir, force: force
    create_file File.join(build_dir, 'index.html'),     index.source,      force: force
    create_file File.join(build_dir, 'application.js'), javascript.source, force: force
    create_file File.join(build_dir, 'stylesheet.css'), stylesheet.source, force: force
  end
end
