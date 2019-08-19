require 'pathname'
require 'ghost_phone/sound'

module GhostPhone

  def self.root
    Pathname.new File.expand_path('../', __dir__)
  end
end
