# frozen_string_literal: true

require_relative 'test_helper'

class DNSFlagsTest < Minitest::Test
  def test_make_with_default_flags
    flags = DNSFlags.make
    assert_equal 0x0100, flags, 'Default flags should set RD=1 and all other flags to 0'
  end

  def test_make_with_custom_flags
    custom_flags = [
      [:QR, 1],      # Response
      [:OP_CODE, 0], # Standard query
      [:AA, 1],      # Authoritative
      [:TC, 0],      # Not truncated
      [:RD, 1],      # Recursion desired
      [:RA, 1],      # Recursion available
      [:Z, 0],       # Reserved
      [:R_CODE, 0]   # No error
    ]
    flags = DNSFlags.make(custom_flags)
    assert_equal 0x8580, flags, 'Custom flags should be properly encoded'
  end

  def test_flags_total_size
    assert_equal 16, DNSFlags::FLAGS_TOTAL_SIZE, 'Total flags size should be 16 bits'
  end

  def test_flags_size_values
    expected_sizes = {
      QR: 1,
      OP_CODE: 4,
      AA: 1,
      TC: 1,
      RD: 1,
      RA: 1,
      Z: 3,
      R_CODE: 4
    }
    assert_equal expected_sizes, DNSFlags::FLAGS_SIZE, 'Flag sizes should match DNS specification'
  end
end
