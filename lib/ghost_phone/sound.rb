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
        exec "aplay #{file_path}"
      end
    end

    def stop
      return if @pid.nil?

      GhostPhone.logger.info "--- sound stopping"
      Process.kill("HUP", @pid)
      Process.detach(@pid)
      @pid = nil
    end
    alias_method :shutdown, :stop
  end
end
