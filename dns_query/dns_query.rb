require_relative 'dns_flags'
require_relative 'dns_header'

module DNSQuery
  CLASSES = {
    IN: 1,
    CS: 2,
    CH: 3,
    HS: 4
  }

  TYPES = {
    A:     1,
    NS:    2,
    MD:    3,
    MF:    4,
    CNAME: 5,
    SOA:   6,
    MB:    7,
    MG:    8,
    MR:    9,
    NULL:  10,
    WKS:   11,
    PTR:   12,
    HINFO: 13,
    MINFO: 14,
    MX:    15,
    TXT:   16
  }

  def make(qname, qclass = CLASSES[:IN], qtype = TYPES[:A])
    flags  = DNSFlags.make
    header = DNSHeader.make(flags)
  
    question = encode_domain(qname) + [qclass, qtype].pack('nn')
    header + question
  end

  module_function :make

  def encode_domain(domain)
    domain
      .split(".")
      .map { |x| x.length.chr + x }
      .join + "\0"
  end

  module_function :encode_domain
end 