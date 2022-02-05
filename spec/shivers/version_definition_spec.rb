# frozen_string_literal: true

require 'spec_helper'

describe Shivers::VersionDefinition do
  describe 'version formats' do
    describe 'for a numeric multipart dot separated version' do
      let(:formatter) do
        ->(v) { [v.major, v.separator, v.minor, v.separator, v.patch] }
      end

      let(:definition) do
        described_class.new(
          parts: {
            major: { type: :numeric },
            minor: { type: :numeric },
            patch: { type: :numeric },
            separator: { type: :static, value: '.' }
          },
          formatter: formatter
        )
      end

      let(:converted_parts) do
        {
          major: P::Numeric.new,
          minor: P::Numeric.new,
          patch: P::Numeric.new,
          separator: P::Static.new(value: '.')
        }
      end

      it 'parses valid version string' do
        expect(definition.parse('1.2.3'))
          .to(eq(V.new(
                   parts: converted_parts,
                   values: { major: 1, minor: 2, patch: 3 },
                   format: F.new(formatter)
                 )))
      end

      it 'allows parts to be zero' do
        expect(definition.parse('0.0.0'))
          .to(eq(V.new(
                   parts: converted_parts,
                   values: { major: 0, minor: 0, patch: 0 },
                   format: F.new(formatter)
                 )))
      end

      it 'allows parts to be multiple digits' do
        expect(definition.parse('12.10.246'))
          .to(eq(V.new(
                   parts: converted_parts,
                   values: { major: 12, minor: 10, patch: 246 },
                   format: F.new(formatter)
                 )))
      end

      it 'throws if required parts missing' do
        expect { definition.parse('.3.1') }
          .to(raise_error(
                ArgumentError,
                "Version string: '.3.1' does not satisfy expected format."
              ))
        expect { definition.parse('1..6') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1..6' does not satisfy expected format."
              ))
        expect { definition.parse('1.6.') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6.' does not satisfy expected format."
              ))
      end
    end

    describe 'for a version with optional metadata part' do
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
        described_class.new(
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

      let(:converted_parts) do
        {
          major: P::Numeric.new,
          minor: P::Numeric.new,
          patch: P::Numeric.new,
          build: P::Numeric.new,
          core_separator: P::Static.new(value: '.'),
          build_separator: P::Static.new(value: '-')
        }
      end

      it 'parses valid version string with optional part' do
        expect(definition.parse('1.2.3-4'))
          .to(eq(V.new(
                   parts: converted_parts,
                   values: { major: 1, minor: 2, patch: 3, build: 4 },
                   format: F.new(formatter)
                 )))
      end

      it 'parses valid version string without optional part' do
        expect(definition.parse('1.2.3'))
          .to(eq(V.new(
                   parts: converted_parts,
                   values: { major: 1, minor: 2, patch: 3, build: nil },
                   format: F.new(formatter)
                 )))
      end

      it 'allows parts to be zero' do
        expect(definition.parse('0.0.0-0'))
          .to(eq(V.new(
                   parts: converted_parts,
                   values: { major: 0, minor: 0, patch: 0, build: 0 },
                   format: F.new(formatter)
                 )))
      end

      it 'allows parts to be multiple digits' do
        expect(definition.parse('12.10.246-1298'))
          .to(eq(V.new(
                   parts: converted_parts,
                   values: { major: 12, minor: 10, patch: 246, build: 1298 },
                   format: F.new(formatter)
                 )))
      end

      it 'throws if required parts missing' do
        expect { definition.parse('.3.1-1') }
          .to(raise_error(
                ArgumentError,
                "Version string: '.3.1-1' does not satisfy expected format."
              ))
        expect { definition.parse('1..6-1') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1..6-1' does not satisfy expected format."
              ))
        expect { definition.parse('1.6.-1') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6.-1' does not satisfy expected format."
              ))
      end

      it 'throws if optional parts partially provided' do
        expect { definition.parse('1.6.2-') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6.2-' does not satisfy expected format."
              ))
      end
    end

    describe 'for a version with optional prerelease and metadata parts' do
      let(:formatter) do
        lambda { |v|
          [
            v.major, v.core_separator,
            v.minor, v.core_separator,
            v.patch,
            v.optionally do |o|
              [o.prerelease_separator,
               o.prerelease_prefix,
               o.prerelease]
            end,
            v.optionally { |o| [o.build_separator, o.build] }
          ]
        }
      end

      let(:definition) do
        described_class.new(
          parts: {
            major: { type: :numeric },
            minor: { type: :numeric },
            patch: { type: :numeric },
            prerelease: { type: :numeric },
            build: { type: :numeric },
            prerelease_prefix: { type: :static, value: 'rc' },
            core_separator: { type: :static, value: '.' },
            prerelease_separator: { type: :static, value: '-' },
            build_separator: { type: :static, value: '+' }
          },
          formatter: formatter
        )
      end

      let(:converted_parts) do
        {
          major: P::Numeric.new,
          minor: P::Numeric.new,
          patch: P::Numeric.new,
          prerelease: P::Numeric.new,
          build: P::Numeric.new,
          prerelease_prefix: P::Static.new(value: 'rc'),
          core_separator: P::Static.new(value: '.'),
          prerelease_separator: P::Static.new(value: '-'),
          build_separator: P::Static.new(value: '+')
        }
      end

      it 'parses valid version string with optional parts' do
        expect(definition.parse('1.2.3-rc4+1234'))
          .to(eq(
                V.new(
                  parts: converted_parts,
                  values: {
                    major: 1, minor: 2, patch: 3, prerelease: 4, build: 1234
                  },
                  format: F.new(formatter)
                )
              ))
      end

      it 'parses valid version string without optional prerelease part' do
        expect(definition.parse('1.2.3+1234'))
          .to(eq(
                V.new(
                  parts: converted_parts,
                  values: {
                    major: 1, minor: 2, patch: 3, prerelease: nil, build: 1234
                  },
                  format: F.new(formatter)
                )
              ))
      end

      it 'parses valid version string without optional build part' do
        expect(definition.parse('1.2.3-rc4'))
          .to(eq(
                V.new(
                  parts: converted_parts,
                  values: {
                    major: 1, minor: 2, patch: 3, prerelease: 4, build: nil
                  },
                  format: F.new(formatter)
                )
              ))
      end

      it 'parses valid version string without all optional parts' do
        expect(definition.parse('1.2.3'))
          .to(eq(
                V.new(
                  parts: converted_parts,
                  values: {
                    major: 1, minor: 2, patch: 3, prerelease: nil, build: nil
                  },
                  format: F.new(formatter)
                )
              ))
      end

      it 'allows parts to be zero' do
        expect(definition.parse('0.0.0-rc0+0'))
          .to(eq(V.new(
                   parts: converted_parts,
                   values: {
                     major: 0, minor: 0, patch: 0, prerelease: 0, build: 0
                   },
                   format: F.new(formatter)
                 )))
      end

      it 'allows parts to be multiple digits' do
        expect(definition.parse('12.10.246-rc1298+764'))
          .to(eq(V.new(
                   parts: converted_parts,
                   values: {
                     major: 12, minor: 10, patch: 246,
                     prerelease: 1298, build: 764
                   },
                   format: F.new(formatter)
                 )))
      end

      it 'throws if required parts missing' do
        expect { definition.parse('.3.1-rc1+5') }
          .to(raise_error(
                ArgumentError,
                "Version string: '.3.1-rc1+5' does not satisfy expected format."
              ))
        expect { definition.parse('1..6-rc1+5') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1..6-rc1+5' does not satisfy expected format."
              ))
        expect { definition.parse('1.6.-rc1+5') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6.-rc1+5' does not satisfy expected format."
              ))
      end

      it 'throws if optional parts partially provided' do
        expect { definition.parse('1.6.2-rc+5') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6.2-rc+5' does not satisfy expected format."
              ))
        expect { definition.parse('1.6.2-rc1+') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6.2-rc1+' does not satisfy expected format."
              ))
      end
    end

    describe 'for a version number with optional alphanumeric prerelease '\
             'part' do
      let(:formatter) do
        lambda { |v|
          [
            v.major, v.core_separator, v.minor,
            v.optionally { |o| [o.prerelease_separator, o.prerelease] }
          ]
        }
      end

      let(:definition) do
        described_class.new(
          parts: {
            major: { type: :numeric },
            minor: { type: :numeric },
            prerelease: { type: :alphanumeric },
            core_separator: { type: :static, value: '.' },
            prerelease_separator: { type: :static, value: '-' }
          },
          formatter: formatter
        )
      end

      let(:converted_parts) do
        {
          major: P::Numeric.new,
          minor: P::Numeric.new,
          prerelease: P::Alphanumeric.new,
          core_separator: P::Static.new(value: '.'),
          prerelease_separator: P::Static.new(value: '-')
        }
      end

      it 'parses valid version string with optional prerelease part' do
        expect(definition.parse('1.2-a2b36d'))
          .to(eq(
                V.new(
                  parts: converted_parts,
                  values: {
                    major: 1, minor: 2, prerelease: 'a2b36d'
                  },
                  format: F.new(formatter)
                )
              ))
      end

      it 'parses valid version string without optional prerelease part' do
        expect(definition.parse('1.2'))
          .to(eq(
                V.new(
                  parts: converted_parts,
                  values: { major: 1, minor: 2, prerelease: nil },
                  format: F.new(formatter)
                )
              ))
      end

      it 'throws if required parts missing' do
        expect { definition.parse('.3-AB1') }
          .to(raise_error(
                ArgumentError,
                "Version string: '.3-AB1' does not satisfy expected format."
              ))
        expect { definition.parse('1..AB1') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1..AB1' does not satisfy expected format."
              ))
      end

      it 'throws if optional parts partially provided' do
        expect { definition.parse('1.6-') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6-' does not satisfy expected format."
              ))
      end
    end

    describe 'for a version number with optional recursive alphanumeric ' \
             'prerelease part' do
      let(:formatter) do
        lambda { |v|
          [
            v.major, v.dot_separator, v.minor,
            v.optionally do |o|
              [
                o.prerelease_separator,
                o.recursively(:prerelease) do |r|
                  r.first { |f| [f.prerelease_identifier] }
                  r.rest { |s| [s.dot_separator, s.prerelease_identifier] }
                end
              ]
            end
          ]
        }
      end

      let(:definition) do
        described_class.new(
          parts: {
            major: { type: :numeric },
            minor: { type: :numeric },
            dot_separator: { type: :static, value: '.' },
            prerelease_separator: { type: :static, value: '-' },
            prerelease_identifier: {
              type: :alphanumeric,
              traits: [:multivalued]
            }
          },
          formatter: formatter
        )
      end

      let(:converted_parts) do
        {
          major: P::Numeric.new,
          minor: P::Numeric.new,
          dot_separator: P::Static.new(value: '.'),
          prerelease_separator: P::Static.new(value: '-'),
          prerelease_identifier: P::Alphanumeric.new(traits: [:multivalued])
        }
      end

      it 'parses valid version string with optional prerelease part with ' \
         'single identifier' do
        expect(definition.parse('1.2-a2b36d'))
          .to(eq(
                V.new(
                  parts: converted_parts,
                  values: {
                    major: 1, minor: 2, prerelease_identifier: ['a2b36d']
                  },
                  format: F.new(formatter)
                )
              ))
      end

      it 'parses valid version string with optional prerelease part with ' \
         'multiple identifiers' do
        expect(definition.parse('1.2-a2b36d.o5y6er.qw32kj'))
          .to(eq(
                V.new(
                  parts: converted_parts,
                  values: {
                    major: 1, minor: 2,
                    prerelease_identifier: %w[a2b36d o5y6er qw32kj]
                  },
                  format: F.new(formatter)
                )
              ))
      end

      it 'parses valid version string without optional prerelease part' do
        expect(definition.parse('1.2'))
          .to(eq(
                V.new(
                  parts: converted_parts,
                  values: { major: 1, minor: 2, prerelease_identifier: nil },
                  format: F.new(formatter)
                )
              ))
      end

      it 'throws if required parts missing' do
        expect { definition.parse('.3-AB1') }
          .to(raise_error(
                ArgumentError,
                "Version string: '.3-AB1' does not satisfy expected format."
              ))
        expect { definition.parse('1..AB1') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1..AB1' does not satisfy expected format."
              ))
      end

      it 'throws if optional parts partially provided' do
        expect { definition.parse('1.6-') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6-' does not satisfy expected format."
              ))
      end

      it 'throws if recursive parts partially provided' do
        expect { definition.parse('1.6-AB1.') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6-AB1.' does not satisfy expected format."
              ))
      end
    end

    describe 'for a version number with optional recursive alphanumeric ' \
             'or hyphen prerelease part and optional recursive alphanumeric ' \
             'or hyphen build part' do
      let(:formatter) do
        lambda { |v|
          [
            v.major, v.dot_separator, v.minor,
            v.optionally do |o|
              [
                o.prerelease_separator,
                o.recursively(:prerelease) do |r|
                  r.first { |f| [f.prerelease_identifier] }
                  r.rest { |s| [s.dot_separator, s.prerelease_identifier] }
                end
              ]
            end,
            v.optionally do |o|
              [
                o.build_separator,
                o.recursively(:build) do |r|
                  r.first { |f| [f.build_identifier] }
                  r.rest { |s| [s.dot_separator, s.build_identifier] }
                end
              ]
            end
          ]
        }
      end

      let(:definition) do
        described_class.new(
          parts: {
            major: { type: :numeric },
            minor: { type: :numeric },
            dot_separator: { type: :static, value: '.' },
            prerelease_separator: { type: :static, value: '-' },
            prerelease_identifier: {
              type: :alphanumeric_or_hyphen,
              traits: [:multivalued]
            },
            build_separator: { type: :static, value: '+' },
            build_identifier: {
              type: :alphanumeric_or_hyphen,
              traits: [:multivalued]
            }
          },
          formatter: formatter
        )
      end

      let(:converted_parts) do
        {
          major: P::Numeric.new,
          minor: P::Numeric.new,
          dot_separator: P::Static.new(value: '.'),
          prerelease_separator: P::Static.new(value: '-'),
          prerelease_identifier:
            P::AlphanumericOrHyphen.new(traits: [:multivalued]),
          build_separator: P::Static.new(value: '+'),
          build_identifier:
            P::AlphanumericOrHyphen.new(traits: [:multivalued])
        }
      end

      it 'parses valid version string with optional prerelease part with ' \
         'single identifier and no optional build part' do
        expect(definition.parse('1.2-a2-b36d'))
          .to(eq(
                V.new(
                  parts: converted_parts,
                  values: {
                    major: 1, minor: 2,
                    prerelease_identifier: ['a2-b36d'],
                    build_identifier: nil
                  },
                  format: F.new(formatter)
                )
              ))
      end

      it 'parses valid version string with optional prerelease part with ' \
         'multiple identifiers and no optional build part' do
        expect(definition.parse('1.2-a2b-36d.o5-y6-er.qw3-2kj'))
          .to(eq(
                V.new(
                  parts: converted_parts,
                  values: {
                    major: 1, minor: 2,
                    prerelease_identifier: %w[a2b-36d o5-y6-er qw3-2kj],
                    build_identifier: nil
                  },
                  format: F.new(formatter)
                )
              ))
      end

      it 'parses valid version string with optional prerelease part with ' \
         'single identifier and optional build part with single identifier' do
        expect(definition.parse('1.2--a2b36d+-o5y6er'))
          .to(eq(
                V.new(
                  parts: converted_parts,
                  values: {
                    major: 1, minor: 2,
                    prerelease_identifier: ['-a2b36d'],
                    build_identifier: ['-o5y6er']
                  },
                  format: F.new(formatter)
                )
              ))
      end

      it 'parses valid version string with optional prerelease part with ' \
         'multiple identifiers and optional build part with multiple ' \
         'identifiers' do
        expect(definition.parse('1.2-a2b36d--.-qw32kj+--o5y6er-.h8kr64--'))
          .to(eq(
                V.new(
                  parts: converted_parts,
                  values: {
                    major: 1, minor: 2,
                    prerelease_identifier: %w[a2b36d-- -qw32kj],
                    build_identifier: %w[--o5y6er- h8kr64--]
                  },
                  format: F.new(formatter)
                )
              ))
      end

      it 'parses valid version string with no optional prerelease part ' \
         'and optional build part with single identifier' do
        expect(definition.parse('1.2+a2b36d'))
          .to(eq(
                V.new(
                  parts: converted_parts,
                  values: {
                    major: 1, minor: 2,
                    prerelease_identifier: nil,
                    build_identifier: ['a2b36d']
                  },
                  format: F.new(formatter)
                )
              ))
      end

      it 'parses valid version string with no optional prerelease part ' \
         'and and optional build part with multiple identifiers' do
        expect(definition.parse('1.2+a2b36d--.-o5y6er-.qw32kj--'))
          .to(eq(
                V.new(
                  parts: converted_parts,
                  values: {
                    major: 1, minor: 2,
                    prerelease_identifier: nil,
                    build_identifier: %w[a2b36d-- -o5y6er- qw32kj--]
                  },
                  format: F.new(formatter)
                )
              ))
      end

      it 'parses valid version string without optional prerelease or ' \
         'build parts' do
        expect(definition.parse('1.2'))
          .to(eq(
                V.new(
                  parts: converted_parts,
                  values: {
                    major: 1, minor: 2,
                    prerelease_identifier: nil,
                    build_identifier: nil
                  },
                  format: F.new(formatter)
                )
              ))
      end

      it 'throws if required parts missing' do
        expect { definition.parse('.3-AB1') }
          .to(raise_error(
                ArgumentError,
                "Version string: '.3-AB1' does not satisfy expected format."
              ))
        expect { definition.parse('1..AB1') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1..AB1' does not satisfy expected format."
              ))
      end

      it 'throws if optional parts partially provided' do
        expect { definition.parse('1.6-') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6-' does not satisfy expected format."
              ))
        expect { definition.parse('1.6+') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6+' does not satisfy expected format."
              ))
      end

      it 'throws if recursive parts partially provided' do
        expect { definition.parse('1.6-AB1.') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6-AB1.' does not satisfy expected format."
              ))
        expect { definition.parse('1.6+AB1.') }
          .to(raise_error(
                ArgumentError,
                "Version string: '1.6+AB1.' does not satisfy expected format."
              ))
      end
    end
  end

  describe 'equality' do
    it 'is equal to other with identical parts and formatter' do
      formatter = ->(v) { [v.prefix, v.major] }
      parts = {
        prefix: { type: :static, value: 'v' },
        major: { type: :numeric }
      }

      first = described_class.new(
        parts: parts, formatter: formatter
      )
      second = described_class.new(
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

      first = described_class.new(
        parts: parts,
        formatter: ->(v) { [v.optionally(&:prefix), v.major] }
      )
      second = described_class.new(
        parts: parts,
        formatter: ->(v) { [v.prefix, v.major] }
      )

      expect(first).not_to(eql(second))
      expect(first).not_to(be == second)
    end

    it 'is not equal to other with different parts' do
      formatter = ->(v) { [v.prefix, v.major] }
      first = described_class.new(
        parts: {
          prefix: { type: :static, value: 'V' },
          major: { type: :numeric }
        },
        formatter: formatter
      )
      second = described_class.new(
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

      first = described_class.new(
        parts: parts, formatter: formatter
      )
      second = Class.new(described_class).new(
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

      first = described_class.new(
        parts: parts, formatter: formatter
      )
      second = described_class.new(
        parts: parts, formatter: formatter
      )

      expect(first.hash).to(eq(second.hash))
    end

    it 'has different hash if other has different formatter' do
      parts = {
        prefix: { type: :static, value: 'v' },
        major: { type: :numeric }
      }

      first = described_class.new(
        parts: parts,
        formatter: ->(v) { [v.optionally(&:prefix), v.major] }
      )
      second = described_class.new(
        parts: parts,
        formatter: ->(v) { [v.prefix, v.major] }
      )

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash if other has different parts' do
      formatter = ->(v) { [v.prefix, v.major] }
      first = described_class.new(
        parts: {
          prefix: { type: :static, value: 'V' },
          major: { type: :numeric }
        },
        formatter: formatter
      )
      second = described_class.new(
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

      first = described_class.new(
        parts: parts, formatter: formatter
      )
      second = Class.new(described_class).new(
        parts: parts, formatter: formatter
      )

      expect(first.hash).not_to(eq(second.hash))
    end
  end
end
