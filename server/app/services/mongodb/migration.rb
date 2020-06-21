module Mongodb
  class Migration

    def self.migrate(direction)
      if direction == :up
        self.up
      end
    rescue
      puts $!
      puts $!.message
      puts $!.backtrace
      raise $!, $!.message
    end

    def self.up
      raise NotImplementedError
    end

    def self.db
      Mongoid::Sessions.default
    end

    def self.info(msg)
      puts msg unless ENV['LOG_LEVEL'] == 'ERROR'
    end
  end
end
