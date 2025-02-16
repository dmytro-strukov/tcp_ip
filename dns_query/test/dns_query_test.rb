# frozen_string_literal: true

require_relative 'test_helper'

class DNSQueryTest < Minitest::Test
  def test_make_query
    domain = 'example.com'
    query = DNSQuery.make(domain)

    # A DNS query should be longer than just the header (12 bytes)
    assert query.length > 12, 'Query should include header and question section'

    # The first 12 bytes should be parseable as a header
    header = DNSHeader.parse(query[0..11])
    assert_equal 6, header.length, 'Header should have 6 components'

    # Check that the domain name is properly encoded in the question section
    encoded_domain = query[12..-5] # Last 4 bytes are class and type
    expected_encoding = "\x07example\x03com\x00"
    assert_equal expected_encoding, encoded_domain, 'Domain should be properly encoded'

    # Check class and type (last 4 bytes)
    qclass, qtype = query[-4..].unpack('nn')
    assert_equal DNSQuery::CLASSES[:IN], qclass, 'Default class should be IN'
    assert_equal DNSQuery::TYPES[:A], qtype, 'Default type should be A'
  end

  def test_make_query_with_custom_class_and_type
    domain = 'example.com'
    query = DNSQuery.make(domain, DNSQuery::CLASSES[:CH], DNSQuery::TYPES[:MX])

    # Check type and class (in that order, as per DNS protocol)
    qtype, qclass = query[-4..].unpack('nn')
    assert_equal DNSQuery::TYPES[:MX], qtype, 'Type should match specified value'
    assert_equal DNSQuery::CLASSES[:CH], qclass, 'Class should match specified value'
  end

  def test_encode_domain
    test_cases = {
      'example.com' => "\x07example\x03com\x00",
      'www.example.com' => "\x03www\x07example\x03com\x00",
      'test.subdomain.example.com' => "\x04test\x09subdomain\x07example\x03com\x00"
    }

    test_cases.each do |domain, expected|
      encoded = DNSQuery.encode_domain(domain)
      assert_equal expected, encoded, "Domain #{domain} should be properly encoded"
    end
  end

  def test_classes_and_types_constants
    assert_equal 1, DNSQuery::CLASSES[:IN], 'IN class should be 1'
    assert_equal 1, DNSQuery::TYPES[:A], 'A record type should be 1'
    assert_equal 15, DNSQuery::TYPES[:MX], 'MX record type should be 15'
  end
end
