# frozen_string_literal: true

require 'spec_helper'

describe Shivers::VersionDefinition do
  context 'version formats' do
    context 'for a simple numeric major.minor version number' do
      let(:formatter) do
        ->(v) { [v.major, v.separator, v.minor] }
      end

      let(:definition) do
        Shivers::VersionDefinition.new(
          parts: {
            major: { type: :numeric },
            minor: { type: :numeric },
            separator: { type: :static, value: '.' }
          },
          formatter: formatter
        )
      end

      it 'parses valid version string' do
        expect(definition.parse('1.2'))
          .to(eq(Shivers::Version2.new(
                   parts: {
                     major: Shivers::Parts::Numeric.new,
                     minor: Shivers::Parts::Numeric.new,
                     separator: Shivers::Parts::Static.new(value: '.')
                   },
                   values: { major: 1, minor: 2 },
                   format: Shivers::Format.new(formatter)
                 )))
      end

      it 'allows parts to be zero' do
        expect(definition.parse('0.0'))
          .to(eq(Shivers::Version2.new(
                   parts: {
                     major: Shivers::Parts::Numeric.new,
                     minor: Shivers::Parts::Numeric.new,
                     separator: Shivers::Parts::Static.new(value: '.')
                   },
                   values: { major: 0, minor: 0 },
                   format: Shivers::Format.new(formatter)
                 )))
      end

      it 'allows parts to be multiple digits' do
        expect(definition.parse('12.246'))
          .to(eq(Shivers::Version2.new(
                   parts: {
                     major: Shivers::Parts::Numeric.new,
                     minor: Shivers::Parts::Numeric.new,
                     separator: Shivers::Parts::Static.new(value: '.')
                   },
                   values: { major: 12, minor: 246 },
                   format: Shivers::Format.new(formatter)
                 )))
      end

      it 'throws if major missing' do
        expect { definition.parse('.3') }
          .to(raise_error(
                ArgumentError,
                "Version string: '.3' does not satisfy expected format."
              ))
      end

      it 'throws if minor missing' do
        expect { definition.parse('1.') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.' does not satisfy expected format."
              ))
      end
    end

    context 'for a numeric major.minor.patch version number' do
      let(:formatter) do
        ->(v) { [v.major, v.separator, v.minor, v.separator, v.patch] }
      end

      let(:definition) do
        Shivers::VersionDefinition.new(
          parts: {
            major: { type: :numeric },
            minor: { type: :numeric },
            patch: { type: :numeric },
            separator: { type: :static, value: '.' }
          },
          formatter: formatter
        )
      end

      it 'parses valid version string' do
        expect(definition.parse('1.2.3'))
          .to(eq(Shivers::Version2.new(
                   parts: {
                     major: Shivers::Parts::Numeric.new,
                     minor: Shivers::Parts::Numeric.new,
                     patch: Shivers::Parts::Numeric.new,
                     separator: Shivers::Parts::Static.new(value: '.')
                   },
                   values: { major: 1, minor: 2, patch: 3 },
                   format: Shivers::Format.new(formatter)
                 )))
      end

      it 'allows parts to be zero' do
        expect(definition.parse('0.0.0'))
          .to(eq(Shivers::Version2.new(
                   parts: {
                     major: Shivers::Parts::Numeric.new,
                     minor: Shivers::Parts::Numeric.new,
                     patch: Shivers::Parts::Numeric.new,
                     separator: Shivers::Parts::Static.new(value: '.')
                   },
                   values: { major: 0, minor: 0, patch: 0 },
                   format: Shivers::Format.new(formatter)
                 )))
      end

      it 'allows parts to be multiple digits' do
        expect(definition.parse('12.10.246'))
          .to(eq(Shivers::Version2.new(
                   parts: {
                     major: Shivers::Parts::Numeric.new,
                     minor: Shivers::Parts::Numeric.new,
                     patch: Shivers::Parts::Numeric.new,
                     separator: Shivers::Parts::Static.new(value: '.')
                   },
                   values: { major: 12, minor: 10, patch: 246 },
                   format: Shivers::Format.new(formatter)
                 )))
      end

      it 'throws if major missing' do
        expect { definition.parse('.3.1') }
          .to(raise_error(
                ArgumentError,
                "Version string: '.3.1' does not satisfy expected format."
              ))
      end

      it 'throws if minor missing' do
        expect { definition.parse('1..6') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1..6' does not satisfy expected format."
              ))
      end

      it 'throws if patch missing' do
        expect { definition.parse('1.6.') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6.' does not satisfy expected format."
              ))
      end
    end

    context 'for a numeric major.minor.patch version number ' \
       'with required build number' do
      let(:formatter) do
        lambda { |v|
          [v.major, v.core_separator, v.minor, v.core_separator, v.patch,
           v.build_separator, v.build]
        }
      end

      let(:definition) do
        Shivers::VersionDefinition.new(
          parts: {
            major: { type: :numeric },
            minor: { type: :numeric },
            patch: { type: :numeric },
            build: { type: :numeric },
            core_separator: { type: :static, value: '.' },
            build_separator: { type: :static, value: '-' }
          },
          formatter: formatter
        )
      end

      it 'parses valid version string' do
        expect(definition.parse('1.2.3-4'))
          .to(eq(Shivers::Version2.new(
                   parts: {
                     major: Shivers::Parts::Numeric.new,
                     minor: Shivers::Parts::Numeric.new,
                     patch: Shivers::Parts::Numeric.new,
                     build: Shivers::Parts::Numeric.new,
                     core_separator: Shivers::Parts::Static.new(value: '.'),
                     build_separator: Shivers::Parts::Static.new(value: '-')
                   },
                   values: { major: 1, minor: 2, patch: 3, build: 4 },
                   format: Shivers::Format.new(formatter)
                 )))
      end

      it 'allows parts to be zero' do
        expect(definition.parse('0.0.0-0'))
          .to(eq(Shivers::Version2.new(
                   parts: {
                     major: Shivers::Parts::Numeric.new,
                     minor: Shivers::Parts::Numeric.new,
                     patch: Shivers::Parts::Numeric.new,
                     build: Shivers::Parts::Numeric.new,
                     core_separator: Shivers::Parts::Static.new(value: '.'),
                     build_separator: Shivers::Parts::Static.new(value: '-')
                   },
                   values: { major: 0, minor: 0, patch: 0, build: 0 },
                   format: Shivers::Format.new(formatter)
                 )))
      end

      it 'allows parts to be multiple digits' do
        expect(definition.parse('12.10.246-1298'))
          .to(eq(Shivers::Version2.new(
                   parts: {
                     major: Shivers::Parts::Numeric.new,
                     minor: Shivers::Parts::Numeric.new,
                     patch: Shivers::Parts::Numeric.new,
                     build: Shivers::Parts::Numeric.new,
                     core_separator: Shivers::Parts::Static.new(value: '.'),
                     build_separator: Shivers::Parts::Static.new(value: '-')
                   },
                   values: { major: 12, minor: 10, patch: 246, build: 1298 },
                   format: Shivers::Format.new(formatter)
                 )))
      end

      it 'throws if major missing' do
        expect { definition.parse('.3.1-1') }
          .to(raise_error(
                ArgumentError,
                "Version string: '.3.1-1' does not satisfy expected format."
              ))
      end

      it 'throws if minor missing' do
        expect { definition.parse('1..6-1') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1..6-1' does not satisfy expected format."
              ))
      end

      it 'throws if patch missing' do
        expect { definition.parse('1.6.-1') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6.-1' does not satisfy expected format."
              ))
      end

      it 'throws if build missing' do
        expect { definition.parse('1.6.2-') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6.2-' does not satisfy expected format."
              ))
      end
    end

    context 'for a numeric major.minor.patch version number ' \
       'with optional build number' do
      let(:formatter) do
        lambda { |v|
          [
            v.major, v.core_separator,
            v.minor, v.core_separator,
            v.patch,
            v.optionally { |o| [o.build_separator, o.build] }
          ]
        }
      end

      let(:definition) do
        Shivers::VersionDefinition.new(
          parts: {
            major: { type: :numeric },
            minor: { type: :numeric },
            patch: { type: :numeric },
            build: { type: :numeric },
            core_separator: { type: :static, value: '.' },
            build_separator: { type: :static, value: '-' }
          },
          formatter: formatter
        )
      end

      it 'parses valid version string with optional part' do
        expect(definition.parse('1.2.3-4'))
          .to(eq(Shivers::Version2.new(
                   parts: {
                     major: Shivers::Parts::Numeric.new,
                     minor: Shivers::Parts::Numeric.new,
                     patch: Shivers::Parts::Numeric.new,
                     build: Shivers::Parts::Numeric.new,
                     core_separator: Shivers::Parts::Static.new(value: '.'),
                     build_separator: Shivers::Parts::Static.new(value: '-')
                   },
                   values: { major: 1, minor: 2, patch: 3, build: 4 },
                   format: Shivers::Format.new(formatter)
                 )))
      end

      it 'parses valid version string without optional part' do
        expect(definition.parse('1.2.3'))
          .to(eq(Shivers::Version2.new(
                   parts: {
                     major: Shivers::Parts::Numeric.new,
                     minor: Shivers::Parts::Numeric.new,
                     patch: Shivers::Parts::Numeric.new,
                     build: Shivers::Parts::Numeric.new,
                     core_separator: Shivers::Parts::Static.new(value: '.'),
                     build_separator: Shivers::Parts::Static.new(value: '-')
                   },
                   values: { major: 1, minor: 2, patch: 3, build: nil },
                   format: Shivers::Format.new(formatter)
                 )))
      end

      it 'allows parts to be zero' do
        expect(definition.parse('0.0.0-0'))
          .to(eq(Shivers::Version2.new(
                   parts: {
                     major: Shivers::Parts::Numeric.new,
                     minor: Shivers::Parts::Numeric.new,
                     patch: Shivers::Parts::Numeric.new,
                     build: Shivers::Parts::Numeric.new,
                     core_separator: Shivers::Parts::Static.new(value: '.'),
                     build_separator: Shivers::Parts::Static.new(value: '-')
                   },
                   values: { major: 0, minor: 0, patch: 0, build: 0 },
                   format: Shivers::Format.new(formatter)
                 )))
      end

      it 'allows parts to be multiple digits' do
        expect(definition.parse('12.10.246-1298'))
          .to(eq(Shivers::Version2.new(
                   parts: {
                     major: Shivers::Parts::Numeric.new,
                     minor: Shivers::Parts::Numeric.new,
                     patch: Shivers::Parts::Numeric.new,
                     build: Shivers::Parts::Numeric.new,
                     core_separator: Shivers::Parts::Static.new(value: '.'),
                     build_separator: Shivers::Parts::Static.new(value: '-')
                   },
                   values: { major: 12, minor: 10, patch: 246, build: 1298 },
                   format: Shivers::Format.new(formatter)
                 )))
      end

      it 'throws if major missing' do
        expect { definition.parse('.3.1-1') }
          .to(raise_error(
                ArgumentError,
                "Version string: '.3.1-1' does not satisfy expected format."
              ))
      end

      it 'throws if minor missing' do
        expect { definition.parse('1..6-1') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1..6-1' does not satisfy expected format."
              ))
      end

      it 'throws if patch missing' do
        expect { definition.parse('1.6.-1') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6.-1' does not satisfy expected format."
              ))
      end

      it 'throws if optional build part partially provided' do
        expect { definition.parse('1.6.2-') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6.2-' does not satisfy expected format."
              ))
      end
    end
  end

  context 'equality' do
    it 'is equal to other with identical parts and formatter' do
      formatter = ->(v) { [v.prefix, v.major] }
      parts = {
        prefix: { type: :static, value: 'v' },
        major: { type: :numeric }
      }

      first = Shivers::VersionDefinition.new(
        parts: parts, formatter: formatter
      )
      second = Shivers::VersionDefinition.new(
        parts: parts, formatter: formatter
      )

      expect(first).to(eql(second))
      expect(first).to(be == second)
    end

    it 'is not equal to other with different formatter' do
      parts = {
        prefix: { type: :static, value: 'v' },
        major: { type: :numeric }
      }

      first = Shivers::VersionDefinition.new(
        parts: parts,
        formatter: ->(v) { [v.optionally(&:prefix), v.major] }
      )
      second = Shivers::VersionDefinition.new(
        parts: parts,
        formatter: ->(v) { [v.prefix, v.major] }
      )

      expect(first).not_to(eql(second))
      expect(first).not_to(be == second)
    end

    it 'is not equal to other with different parts' do
      formatter = ->(v) { [v.prefix, v.major] }
      first = Shivers::VersionDefinition.new(
        parts: {
          prefix: { type: :static, value: 'V' },
          major: { type: :numeric }
        },
        formatter: formatter
      )
      second = Shivers::VersionDefinition.new(
        parts: {
          prefix: { type: :static, value: 'v' },
          major: { type: :numeric }
        },
        formatter: formatter
      )

      expect(first).not_to(eql(second))
      expect(first).not_to(be == second)
    end

    it 'is not equal to other of different type' do
      formatter = ->(v) { [v.prefix, v.major] }
      parts = {
        prefix: { type: :static, value: 'v' },
        major: { type: :numeric }
      }

      first = Shivers::VersionDefinition.new(
        parts: parts, formatter: formatter
      )
      second = Class.new(Shivers::VersionDefinition).new(
        parts: parts, formatter: formatter
      )

      expect(first).not_to(eql(second))
      expect(first).not_to(be == second)
    end

    it 'has the same hash if equal' do
      formatter = ->(v) { [v.prefix, v.major] }
      parts = {
        prefix: { type: :static, value: 'v' },
        major: { type: :numeric }
      }

      first = Shivers::VersionDefinition.new(
        parts: parts, formatter: formatter
      )
      second = Shivers::VersionDefinition.new(
        parts: parts, formatter: formatter
      )

      expect(first.hash).to(eq(second.hash))
    end

    it 'has different hash if other has different formatter' do
      parts = {
        prefix: { type: :static, value: 'v' },
        major: { type: :numeric }
      }

      first = Shivers::VersionDefinition.new(
        parts: parts,
        formatter: ->(v) { [v.optionally(&:prefix), v.major] }
      )
      second = Shivers::VersionDefinition.new(
        parts: parts,
        formatter: ->(v) { [v.prefix, v.major] }
      )

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash if other has different parts' do
      formatter = ->(v) { [v.prefix, v.major] }
      first = Shivers::VersionDefinition.new(
        parts: {
          prefix: { type: :static, value: 'V' },
          major: { type: :numeric }
        },
        formatter: formatter
      )
      second = Shivers::VersionDefinition.new(
        parts: {
          prefix: { type: :static, value: 'v' },
          major: { type: :numeric }
        },
        formatter: formatter
      )

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash if other has different type' do
      formatter = ->(v) { [v.prefix, v.major] }
      parts = {
        prefix: { type: :static, value: 'v' },
        major: { type: :numeric }
      }

      first = Shivers::VersionDefinition.new(
        parts: parts, formatter: formatter
      )
      second = Class.new(Shivers::VersionDefinition).new(
        parts: parts, formatter: formatter
      )

      expect(first.hash).not_to(eq(second.hash))
    end
  end
end
