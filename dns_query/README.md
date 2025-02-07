module DNSQuery
  # Request identifier. 
  # This is a random number that is used to request a response.
  # 16 bytes = (2 to the 16th power) - 1 = 0..65535
  QUERY_ID_SIZE = 16 

  # DNS Query Flags:
  #
  # ID (16 bit) identifier assigned by the program that generates any kind of query.  
  # This identifier is copied the corresponding reply and can be used by the requester 
  # to match up replies to outstanding queries.
  #
  # QR (1 bit) [Query/Response]:
  #   0 — Query
  #   1 — Response
  #
  # Opcode (4 bit) [Query Type]:
  #   0 — Standard query (QUERY)
  #   1 — Inverse query (IQUERY)
  #   2 — Status query (STATUS)
  #   3 — Reserved for future use
  #
  # AA (1 bit) [Authoritative Answer]:
  #   0 — Response is not authoritative
  #   1 — Response is authoritative (only in response)
  #
  # TC (1 bit) [Truncated]:
  #   0 — Response was not truncated
  #   1 — Response was truncated (if it exceeds the maximum packet size)
  #
  # RD (1 bit) [Recursion Desired]:
  #   0 — Recursion not requested
  #   1 — Client requests recursive query
  #
  # RA (1 bit) [Recursion Available]:
  #   0 — Server does not support recursion
  #   1 — Server supports recursion (only in response)
  #
  # Z (3 bit) [Reserved]:
  #   Reserved, must be 0
  #
  # Rcode (4 bit) [Response Code] — Response Code:
  #   0 — No error (NOERROR)
  #   1 — Format error (FORMERR)
  #   2 — Server failure (SERVFAIL)
  #   3 — Name does not exist (NXDOMAIN)
  #   4 — Not implemented (NOTIMP)
  #   5 — Query refused (REFUSED)
  #   6 — Name server not found (NOTAUTH)
  #   7 — Can't find the domain (NXRRSET)
  #   8 — Range error (NOTZONE)
  #
  # Example of flags:
  # 1. Query with recursion:
  #    0x0100 (QR=0, Opcode=0, AA=0, TC=0, RD=1)
  # 2. Response with recursion and successful code:
  #    0x8180 (QR=1, Opcode=0, AA=0, TC=0, RD=0, RA=1, Rcode=0)
  # DNS Header = 16 bits
  # | QR | Opcode  | AA | TC | RD | RA | Z  | Rcode |
  # |----|---------|----|----|----|----|----|-------|
  # |  1 |    4    |  1 |  1 |  1 |  1 |  3 |   4   |
  

  FLAGS_TOTAL_SIZE = 16
  FLAGS_SIZE = {
    QR: 1,
    OP_CODE: 4,
    AA: 1,
    TC: 1,
    RD: 1,
    RA: 1,
    Z: 3,
    R_CODE: 4
  }

  DEFAULT_QUERY_FLAGS = [
    [:QR, 0],
    [:OP_CODE, 0],
    [:AA, 0],
    [:TC, 0],
    [:RD, 1],
    [:RA, 0],
    [:Z, 0],
    [:R_CODE, 0] 
  ]

  CLASS_VALUES = {
    IN: 1,
    CS: 2,
    CH: 3,
    HS: 4
  }

  DNS_RECORD_TYPES = {
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
  
  def build_flags(flags = DEFAULT_QUERY_FLAGS)
    output = 0
    available_bits = FLAGS_TOTAL_SIZE

    flags.each_with_index do |flag, index|
      name, value = flag
      available_bits -= FLAGS_SIZE.fetch(name)

      if flags[index] != flags.last
        output |= value << available_bits
      else
        output |= value
      end
    end

    output
  end

  QD_COUNT = 0x0001 # number of entries in the question section
  AN_COUNT = 0x0000 # number of resource records in the answer section
  NS_COUNT = 0x0000 # number of name server resource records in the authority records section
  AR_COUNT = 0x0000 # number of resource records in the additional records section

  def build_header(qd_count = QD_COUNT, an_count = AN_COUNT, ns_count = NS_COUNT, ar_count = AR_COUNT)
    query_id = rand(range_from_bits(QUERY_ID_SIZE))

    [
      query_id,
      build_flags(),
      qd_count,
      an_count,
      ns_count,
      ar_count
    ].pack('6n') # n | Integer | 16-bit unsigned, network (big-endian) byte order
  end

  def encode_domain(domain)
    domain
      .split(".")
      .map { |x| x.length.chr + x }
      .join + "\0"
  end

  # DNS Query Question Section Structure:
  #
  # 1. Domain Name:
  #    - The domain name is encoded as a sequence of labels.
  #    - Each label consists of one byte indicating the length of the label, followed by the bytes of the label itself.
  #    - For example, for the domain "example.com":
  #      07 (length of "example") | 65 78 61 6D 70 6C 65 ("example")
  #      03 (length of "com")     | 63 6F 6D ("com")
  #      00 (terminating byte, indicating the end of the domain name)
  #
  # 2. Type:
  #    - The type of record being requested in the DNS query.
  #    - Example: A record (IPv4 address) — 0x0001
  #    - Example: MX record (Mail Exchange) — 0x000F
  #    - Example: CNAME (Canonical Name) — 0x0005
  #
  # 3. Class:
  #    - The class of the DNS record, typically always IN (Internet), encoded as 0x0001.
  #
  # Example:
  #   For requesting an A record for the domain "example.com":
  #   - Domain Name: 07 65 78 61 6D 70 6C 65 03 63 6F 6D 00
  #   - Type: 0x0001 (A record)
  #   - Class: 0x0001 (IN)
  #
  # Full Example Question Section:
  #   07 65 78 61 6D 70 6C 65 03 63 6F 6D 00 00 01 00 01
  #   Where:
  #     - 07 (length of "example")
  #     - 65 78 61 6D 70 6C 65 ("example")
  #     - 03 (length of "com")
  #     - 63 6F 6D ("com")
  #     - 00 (end of domain name)
  #     - 00 01 (A record type)
  #     - 00 01 (IN class)

  def create(domain, class_value = CLASS_VALUES[:IN], dns_record_type = DNS_RECORD_TYPES[:A])
    header   = build_header()
    question = encode_domain_name(domain) + [class_value, dns_record_type].pack('nn')

    header + question
  end
end


def dns_query(domain)
  # Create a UDP socket
  socket = UDPSocket.new

  # DNS server address (Google Public DNS)
  dns_server = '8.8.8.8'
  dns_port = 53

  # Build DNS query
  query = build_dns_query(domain)

  # Send the query
  socket.send(query, 0, dns_server, dns_port)

  # Receive the response
  response, _ = socket.recvfrom(512)

  # Close the socket
  socket.close

  # Parse and return the response
  parse_dns_response(response)
end

def build_dns_query(domain)
  # DNS header
  id = rand(0..65535) # Random transaction ID
  flags = 0x0100 # Standard query with recursion
  qdcount = 1 # Number of questions
  ancount = 0 # Number of answers
  nscount = 0 # Number of authority records
  arcount = 0 # Number of additional records

  # Build the header
  header = [id, flags, qdcount, ancount, nscount, arcount].pack('n6')

  # Build the question
  question = domain.split('.').map { |label| [label.length, label].pack('Ca*') }.join
  question += "\x00" # Null byte to end the domain name
  question += [1, 1].pack('n2') # Type A, Class IN

  # Combine header and question
  header + question
end

def parse_dns_response(response)
  # Extract the header
  header = response[0, 12]
  id, flags, qdcount, ancount, nscount, arcount = header.unpack('n6')

  # Check if the response is valid
  if (flags & 0x8000) == 0 && (flags & 0x000F) == 0
    return "Invalid response"
  end

  # Skip the question section
  offset = 12
  qdcount.times do
    while response[offset].ord != 0
      offset += response[offset].ord + 1
    end
    offset += 5 # Skip null byte and type/class
  end

  # Parse the answer section
  answers = []
  ancount.times do
    # Read the name (compressed)
    name, offset = read_name(response, offset)
    type, cls, ttl, rdlength = response[offset, 10].unpack('n3Nn')
    offset += 10
    rdata = response[offset, rdlength]
    answers << { name: name, type: type, class: cls, ttl: ttl, data: rdata.unpack('C*') }
    offset += rdlength
  end

  answers
end

def read_name(response, offset)
  name = ''
  while response[offset].ord != 0
    if response[offset].ord & 0xC0 == 0xC0
      # Pointer to another name
      pointer = response[offset].ord & 0x3F
      offset += 1
      name += read_name(response, pointer)[0]
      break
    else
      length = response[offset].ord
      offset += 1
      name += response[offset, length] + '.'
      offset += length
    end
  end
  [name.chomp('.'), offset + 1] # Remove trailing dot and return
end

# Example usage
puts dns_query('example.com').inspect