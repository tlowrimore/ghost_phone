require 'pathname'
require 'logger'

require 'ghost_phone/message'
require 'ghost_phone/serial'
require 'ghost_phone/sound'
require 'ghost_phone/state_manager'

module GhostPhone
  SERIAL_PORT = '/dev/serial0'
  BAUD_RATE   = 115200

  # -----------------------------------------------------
  # Class Methods
  # -----------------------------------------------------

  def self.root
    Pathname.new File.expand_path('../', __dir__)
  end

  def self.logger
    @logger ||= begin
      formatter = Logger::Formatter.new
      level     = ENV['LOG_LEVEL'] || :info

      Logger.new(STDOUT, level: level).tap do |logger|
        logger.formatter = proc do |severity, datetime, progname, msg|
          formatter.call(severity, datetime, progname, msg.dump)
        end
      end
    end
  end

  def self.start
    return if @runner

    @runner = Runner.new

    Signal.trap("INT") do
      logger.info '--- shutting down'
      @runner.stop
      @runner = nil
      exit
    end

    Signal.trap("TERM") do
      logger.warn '--- terminating!'
      @runner.stop
      @runner = nil
      exit
    end

    @runner.start
  end

  # -----------------------------------------------------
  # Runner
  # -----------------------------------------------------

  class Runner
    def initialize
      @state_manager  = GhostPhone::StateManager.new
      @serial         = GhostPhone::Serial.new(SERIAL_PORT, BAUD_RATE)
      @sound          = nil
      @message        = nil
    end

    def start
      GhostPhone.logger.info "--- starting serial monitor"
      @serial.monitor { |value| update(value) }
    end

    def stop
      @serial.stop
      @sound.shutdown   if @sound
      @message.shutdown if @message
    end

    def update(value)
      GhostPhone.logger.debug "--- updating state with: '#{value}'"
      event, key  = value[0], value[1]
      state       = @state_manager.update(event, key)

      GhostPhone.logger.debug "--- current state: #{state.inspect}"

      play_dial_tone                  if state.ready?
      play_tone(key)                  if state.play_tone?
      stop_tone                       if state.stop_tone?
      record_message(state.file_name) if state.recording?
      stop_recording                  if state.hangup?
    end

    # -----------------------------------------------------
    # Private Methods
    # -----------------------------------------------------

    private

    def play_dial_tone
      play_tone(GhostPhone::Sound::DIAL_TONE)
    end

    def play_tone(key)
      stop_tone
      @sound = GhostPhone::Sound.new(key)
      @sound.play
    end

    def stop_tone
      @sound.stop if @sound
    end

    def record_message(file_name)
      return unless @message.nil?
      @message = GhostPhone::Message.new(file_name)
      @message.record
    end

    def stop_recording
      return if @message.nil?
      @message.stop
      @message = nil
    end
  end
end
