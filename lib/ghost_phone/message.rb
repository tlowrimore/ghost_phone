module GhostPhone
  class Message
    MSG_DIR = 'data/messages'

    attr_reader :name

    def initialize(name)
      @name = name
      @pid  = nil
    end

    def file_name
      @file_name ||= "#{name}.wav"
    end

    def file_path
      @file_path ||= GhostPhone.root.join(MSG_DIR, file_name).to_s
    end

    def record
      @pid = fork do
        exec "arecord -f S16_LE -D plughw:1,0 -r 44100 #{file_path}"
      end
    end

    def stop
      GhostPhone.logger.info "--- recorder stopping"
      Process.kill("INT", @pid) if @pid
    end

    def shutdown
      GhostPhone.logger.info "--- recorder shutdown"
      Process.kill("TERM", @pid) if @pid
    end
  end
end
