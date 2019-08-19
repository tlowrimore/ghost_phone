module GhostPhone
  class StateManager
    STATE_ON_HOOK         = 1
    STATE_READY_FOR_INPUT = 2
    STATE_DIALING         = 3
    STATE_RECORDING       = 4

    EVENT_PRESS   = 'v'
    EVENT_RELEASE = '^'

    KEY_HOOK      = 'h'
    KEY_STAR      = '*'
    KEY_HASH      = '#'

    NUMERIC = /\d/

    attr_reader :state, :last_event, :last_key

    def initialize
      reset
    end

    def update(event, key)
      GhostPhone.logger.debug "--- state update called with { event: '#{event}', key: '#{key}'}"

      @last_event  = event

      if event == EVENT_PRESS

        case key
        when KEY_HOOK
          pickup
        when KEY_STAR
          begin_recording
        else
          dial(key)
        end

      elsif event == EVENT_RELEASE
        reset if key == KEY_HOOK
      end

      self
    end

    def file_name
      @file_name_buffer.join('')
    end

    def reset
      GhostPhone.logger.info '--- resetting state'
      @state            = STATE_ON_HOOK
      @last_event       = EVENT_RELEASE
      @last_key         = KEY_HOOK
      @file_name_buffer = []
    end

    def ready?
      state == STATE_READY_FOR_INPUT
    end

    def dialing?
      state == STATE_DIALING
    end

    def recording?
      state == STATE_RECORDING
    end

    def hangup?
      state == STATE_ON_HOOK
    end

    def key_pressed?
      last_event == EVENT_PRESS
    end

    def key_released?
      last_event == EVENT_RELEASE
    end

    def key_tone?
      last_key != KEY_HOOK
    end

    def key_hook?
      last_key == KEY_HOOK
    end

    def play_tone?
      (dialing? || recording?) && key_pressed? && key_tone?
    end

    def stop_tone?
      hangup? || ((dialing? || recording?) && key_released? && key_tone?)
    end

    # -----------------------------------------------------
    # Private
    # -----------------------------------------------------

    private

    def pickup
      GhostPhone.logger.debug "--- state transition: pickup"
      @state    = STATE_READY_FOR_INPUT
      @last_key = KEY_HOOK
    end

    def dial(key)
      if state == STATE_READY_FOR_INPUT || state == STATE_DIALING
        GhostPhone.logger.debug "--- state transition dial:  { key: '#{key}' }"

        @state            = STATE_DIALING
        @last_key         = key
        @file_name_buffer << key if key.to_s =~ NUMERIC
      end
    end

    def begin_recording
      if state == STATE_DIALING
        GhostPhone.logger.debug "--- state transition recording"
        @state = STATE_RECORDING
      else

        GhostPhone.logger.error "--- An invalid state transition has occured!  Resetting!"
        reset
      end
    end
  end
end
