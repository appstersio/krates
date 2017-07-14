module Kontena
  module Helpers
    module LauncherHelper
      include Kontena::Logging

      # @param name [String]
      # @return [Docker::Container] nil if not found
      def inspect_image(name)
        Docker::Image.get(name)
      rescue Docker::Error::NotFoundError
        nil
      end

      # @param name [String]
      # @return [Docker::Image]
      def ensure_image(name)
        unless image = inspect_image(name)
          info "Pulling image #{name}..."
          image = Docker::Image.create('fromImage' => name)
        end
        debug "Ensure image #{name}: #{image.id}"
        image
      end

      # @param name [String]
      # @return [Docker::Container] nil if not found
      def inspect_container(name)
        Docker::Container.get(name)
      rescue Docker::Error::NotFoundError
        nil
      end
    end
  end
end
