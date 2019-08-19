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
        Signal.trap("HUP") do
          GhostPhone.logger.info "--- recorder stopping"
          exit
        end
        
        exec "arecord -f S16_LE -D plughw:1,0 -r 44100 #{file_path}"
      end
    end

    def stop
      Process.kill("HUP", @pid) if @pid
    end

    def shutdown
      GhostPhone.logger.info "--- recorder shutdown"
      Process.kill("HUP", @pid) if @pid
    end
  end
end
