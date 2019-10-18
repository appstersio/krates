module Kontena
  module PluginManager
    autoload :RubygemsClient, 'kontena/plugin_manager/rubygems_client'
    autoload :Loader, 'kontena/plugin_manager/loader'
    autoload :Installer, 'kontena/plugin_manager/installer'
    autoload :Uninstaller, 'kontena/plugin_manager/uninstaller'
    autoload :Cleaner, 'kontena/plugin_manager/cleaner'
    autoload :Common, 'kontena/plugin_manager/common'

    # Initialize plugin manager
    def init
      # TODO: Figure out how to co-exist with Bundler's post_reset hook
      # that restores specs captured by Bundler's closure originally
      Gem.post_reset_hooks.delete_if {|h| h.to_s.match /bundler/}
      ENV["GEM_HOME"] = Common.install_dir
      Gem.paths = ENV
      Common.use_dummy_ui unless Kontena.debug?
      plugins
      true
    end
    module_function :init

    # @return [Array<Gem::Specification>]
    def plugins
      @plugins ||= Loader.new.load_plugins
    end
    module_function :plugins
  end
end
