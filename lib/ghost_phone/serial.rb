require 'serialport'

module GhostPhone
  class Serial

    attr_reader :port, :baud_rate

    def initialize(port, baud_rate)
      @port       = port
      @baud_rate  = baud_rate
      @monitor    = nil
    end

    def monitor(&block)
      return unless @monitor.nil?

      Signal.trap("INT") do
        stop
      end

      @monitor = Thread.new(reader, block) do |reader, callback|
        reader.read do |value|
          callback.(value.strip)
        end
      end
    end

    def stop
      return if @monitor.nil?

      reader.stop
      @monitor.kill
      @monitor = nil
    end

    # -----------------------------------------------------
    # Private Methods
    # -----------------------------------------------------

    private

    def reader
      @reader ||= SerialPort.new(port, baud_rate)
    end
  end
end
