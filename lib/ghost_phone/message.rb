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
        exec "arecord -fcd #{file_path}"
      end
    end

    def stop
      Process.kill("HUP", @pid) if @pid
    end
  end
end
