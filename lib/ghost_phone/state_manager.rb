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

    attr_reader :state, :event, :key

    def initialize
      reset
    end

    def update(event, key)
      @event  = event

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
        reset if key_hook?
      end

      self
    end

    def file_name
      @file_name_buffer.join('')
    end

    def reset
      GhostPhone.logger.info '--- resetting state'
      @state            = STATE_ON_HOOK
      @event            = nil
      @key              = nil
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
      event == EVENT_PRESS
    end

    def key_released?
      event == EVENT_RELEASE
    end

    def key_tone?
      key != KEY_HOOK
    end

    def key_hook?
      key == KEY_HOOK
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
      @state = STATE_READY_FOR_INPUT
    end

    def dial(key)
      if state == STATE_READY_FOR_INPUT || state == STATE_DIALING
        @state            = STATE_DIALING
        @key              = key
        @file_name_buffer << key unless key == KEY_HASH
      end
    end

    def begin_recording
      if state == STATE_DIALING
        @state = STATE_RECORDING
      else

        # Just start over if we get here!
        reset
        pickup
      end
    end
  end
end
