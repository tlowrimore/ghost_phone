module GhostPhone
  class Sound
    SOUND_DIR = 'data/sound'

    DIAL_TONE = 'dial'

    NAME_MAP  = {
      '#' => 'hash',
      '*' => 'star'
    }

    attr_reader :name

    def initialize(name)
      @name = name
      @pid  = nil
    end

    def file_name
      @file_name ||= begin
        stem = NAME_MAP[name] || name
        "#{stem}.wav"
      end
    end

    def file_path
      @file_path ||= GhostPhone.root.join(SOUND_DIR, file_name).to_s
    end

    def play
      @pid = fork do
        Signal.trap("HUP") do
          GhostPhone.logger.info "--- sound stopping"
          exit
        end
        
        exec "aplay #{file_path}"
      end
    end

    def stop
      Process.kill("HUP", @pid) if @pid
    end

    def shutdown
      GhostPhone.logger.info "--- shutting down sound player"
      Process.kill("HUP", @pid) if @pid
    end
  end
end
