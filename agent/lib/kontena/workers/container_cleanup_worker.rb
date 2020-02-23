module Kontena::Workers
    class ContainerCleanupWorker
      include Celluloid
      include Kontena::Logging
  
      CLEANUP_INTERVAL = 60
      # Remove only containers exited 5+ minutes ago
      GRACE_PERIOD_IN_MINUTES = 5
  
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
            # Skip containers within the grace period
            next if minutes_ago(container.info['Status']) < GRACE_PERIOD_IN_MINUTES
            # Remove containers outside of the grace period
            container.remove
            info "Removed exited container: #{container.id}"
          rescue
            error "Failed to remove exited container: #{container.id}"
          end
        end
      end

      def minutes_ago(status)
        # Set initial state and match minutes
        m = /(\d+) minute/.match(status)
        # Convert from minutes
        return m[1].to_i if m
        # Match hours
        h = /(\d+) hour/.match(status)
        # Convert from hours
        return h[1].to_i * 60 if h
        # Match days
        d = /(\d+) day/.match(status)
        # Convert from days
        return d[1].to_i * 1440 if d
        # By default it is 0
        return 0
      end
    end
end