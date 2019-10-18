module Kontena::Cli::Plugins
  module Common

    def short_name(name)
      name.sub('krates-plugin-', '')
    end
  end
end
