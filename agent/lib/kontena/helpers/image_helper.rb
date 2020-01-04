module Kontena
  module Helpers
    module ImageHelper

      # @param [String] image
      def pull_image(image)
        if Docker::Image.exist?(image)
          info "image already exist: #{image}"
          return
        end
        info "pulling image: #{image}"
        Docker::Image.create('fromImage' => image)
        sleep 1 until Docker::Image.exist?(image)
        info "pulled image: #{image}"
      end

    end
  end
end
