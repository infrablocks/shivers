require 'shivers/version'

require 'semantic'

module Shivers
  class Version
    def self.from_file(path)
      git_sha = ENV['GIT_SHA'] || 'LOCAL'
      metadata = "#{git_sha}"

      base_version = File.exist?(path) ?
          File.open(path) { |file| file.read.strip } :
          '0.0.0'

      Version.new("#{base_version}+#{metadata}")
    end

    def initialize(version_string)
      @version = Semantic::Version.new(version_string)
    end

    def to_docker_tag
      to_s.gsub(/[\+]/, '_').downcase
    end

    def to_s
      @version.to_s
    end
  end
end
