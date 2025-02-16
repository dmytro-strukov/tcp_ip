# frozen_string_literal: true

require_relative 'test_helper'

class DNSHeaderTest < Minitest::Test
  def test_make_creates_valid_header
    flags = DNSFlags.make
    header = DNSHeader.make(flags)

    # Header should be 12 bytes (6 16-bit words)
    assert_equal 12, header.length, 'Header should be 12 bytes long'

    # Parse the header back
    parsed = DNSHeader.parse(header)
    assert_equal 6, parsed.length, 'Parsed header should have 6 components'

    # Check the components
    query_id, parsed_flags, qd_count, an_count, ns_count, ar_count = parsed

    assert query_id.between?(0, 65_535), 'Query ID should be between 0 and 65535'
    assert_equal flags, parsed_flags, 'Flags should match the input'
    assert_equal DNSHeader::QD_COUNT, qd_count, 'QD_COUNT should match default'
    assert_equal DNSHeader::AN_COUNT, an_count, 'AN_COUNT should match default'
    assert_equal DNSHeader::NS_COUNT, ns_count, 'NS_COUNT should match default'
    assert_equal DNSHeader::AR_COUNT, ar_count, 'AR_COUNT should match default'
  end

  def test_make_with_custom_counts
    flags = DNSFlags.make
    custom_qd = 2
    custom_an = 1
    custom_ns = 1
    custom_ar = 1

    header = DNSHeader.make(flags, custom_qd, custom_an, custom_ns, custom_ar)
    parsed = DNSHeader.parse(header)

    _, _, qd_count, an_count, ns_count, ar_count = parsed
    assert_equal custom_qd, qd_count, 'Custom QD_COUNT should be used'
    assert_equal custom_an, an_count, 'Custom AN_COUNT should be used'
    assert_equal custom_ns, ns_count, 'Custom NS_COUNT should be used'
    assert_equal custom_ar, ar_count, 'Custom AR_COUNT should be used'
  end

  def test_range_from_bits
    range = DNSHeader.range_from_bits(16)
    assert_equal (0..65_535), range, '16 bits should give range 0..65535'

    range = DNSHeader.range_from_bits(8)
    assert_equal (0..255), range, '8 bits should give range 0..255'
  end
end
