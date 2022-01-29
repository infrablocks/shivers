# frozen_string_literal: true

require 'spec_helper'

describe Shivers::Version do
  include FakeFS::SpecHelpers

  describe '.from_file' do
    it 'uses a version of 0.0.0 and a git SHA of LOCAL by default' do
      version = described_class.from_file('non/existing/path')

      expect(version.to_s)
        .to(eq('0.0.0+LOCAL'))
    end

    it 'reads the git SHA from the GIT_SHA environment variable when present' do
      with_env(GIT_SHA: 'ab4d') do
        version = described_class.from_file('non/existing/path')

        expect(version.to_s)
          .to(eq('0.0.0+ab4d'))
      end
    end

    it 'reads the version number from the provided path when it exists' do
      path = 'some/version/file'

      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') do |file|
        file.write("1.2.0\n")
      end

      version = described_class.from_file(path)

      expect(version.to_s)
        .to(eq('1.2.0+LOCAL'))
    end
  end

  describe '.new' do
    it 'throws if version string is not a valid semantic vesion' do
      expect do
        described_class.new('wat')
      end.to(raise_error(ArgumentError))
    end
  end

  describe '#to_docker_tag' do
    it 'converts + to underscore in the version string' do
      version = described_class.new('1.2.3+1bcd')

      expect(version.to_docker_tag)
        .to(eq('1.2.3_1bcd'))
    end

    it 'converts the string to lowercase' do
      version = described_class.new('1.2.3-RC.1+LOCAL')

      expect(version.to_docker_tag)
        .to(eq('1.2.3-rc.1_local'))
    end
  end

  def with_env(env_hash, &block)
    env_hash.each { |key, value| ENV[key.to_s] = value.to_s }
    block.call
    env_hash.each { |key, _| ENV.delete(key.to_s) }
  end
end
