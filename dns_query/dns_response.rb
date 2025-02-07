require_relative 'dns_header'

module DNSResponse
  def parse(bytes)
    query_id, flags, qd_count, an_count, ns_count, ar_count = DNSHeader.parse(bytes.byteslice(0, 11))
  end

  module_function :parse
end 