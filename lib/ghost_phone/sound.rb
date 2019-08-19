require 'easy_audio'
require 'wavefile'

module GhostPhone
  class Sound
    SOUND_DIR = 'data/sound'
    NAME_MAP  = {
      '#' => 'hash',
      '*' => 'star',
      'h' => 'dial'
    }

    attr_reader :name

    def initialize(name)
      @name = name
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
      Process.kill("HUP", @pid) if @pid
    end
  end
end
