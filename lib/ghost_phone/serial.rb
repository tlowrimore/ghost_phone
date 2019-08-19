require 'serialport'

module GhostPhone
  class Serial

    # Standard Arduino Serial Config
    DATA_BITS     = 8
    STOP_BITS     = 1
    PARITY        = SerialPort::NONE

    attr_reader :port, :baud_rate

    def initialize(port, baud_rate)
      @port       = port
      @baud_rate  = baud_rate
      @monitor    = nil
    end

    def monitor(&block)
      return unless @monitor.nil?

      @monitor = Thread.new(reader, block) do |reader, callback|
        GhostPhone.logger.info "--- monitor thread started"
        while true
          value = reader.gets
          callback.(value.chomp) unless value.nil?
        end
      end

      GhostPhone.logger.debug "--- monitor thread joining"
      @monitor.join
    end

    def stop
      return if @monitor.nil?
      GhostPhone.logger.info "--- serial monitor stopping"
      reader.stop
      @monitor.kill
      @monitor = nil
    end

    # -----------------------------------------------------
    # Private Methods
    # -----------------------------------------------------

    private

    def reader
      @reader ||= SerialPort.new(port, baud_rate, DATA_BITS, STOP_BITS, PARITY)
    end
  end
end
