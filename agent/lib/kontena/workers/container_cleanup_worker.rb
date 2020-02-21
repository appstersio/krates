module Kontena::Workers
    class ContainerCleanupWorker
      include Celluloid
      include Kontena::Logging
  
      CLEANUP_INTERVAL = 60
      CLEANUP_DELAY = (60*60)
  
      ##
      # @param [Boolean] autostart
      def initialize(autostart = true)
        info 'initialized'
        async.start if autostart
      end

      def start
        loop do
          sleep CLEANUP_INTERVAL
          cleanup_containers
        end
      end

      def cleanup_containers
        containers = Docker::Container.all(all: true, filters: { status: ["exited"]}.to_json)
        containers.each do |container|
          begin
            container.remove
            info "Removed exited container: #{container.id}"
          rescue
            error "Failed to remove exited container: #{container.id}"
          end
        end
      end
    end
end