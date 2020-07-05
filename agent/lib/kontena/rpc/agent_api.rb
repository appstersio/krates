require_relative '../models/node'

module Kontena
  module Rpc
    class AgentApi

      # @param [Hash] data
      def master_info(data)
        Celluloid::Notifications.publish('websocket:connected', {master: data})
        {}
      end

      # @param [Hash] data
      def node_info(data)
        node = Node.new(data)
        Celluloid::Notifications.publish('agent:node_info', node)
        {}
      end
    end
  end
end
