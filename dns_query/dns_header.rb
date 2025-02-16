# frozen_string_literal: true

module DNSHeader
  ID_SIZE = 16

  QD_COUNT = 0x0001
  AN_COUNT = 0x0000
  NS_COUNT = 0x0000
  AR_COUNT = 0x0000

  def parse(bytes)
    bytes.unpack('nnnnnn')
  end

  module_function :parse

  def make(flags, qd_count = QD_COUNT, an_count = AN_COUNT, ns_count = NS_COUNT, ar_count = AR_COUNT)
    query_id = rand(range_from_bits(ID_SIZE))

    [
      query_id,
      flags,
      qd_count,
      an_count,
      ns_count,
      ar_count
    ].pack('nnnnnn')
  end

  module_function :make

  def range_from_bits(bits)
    Range.new(
      0,
      (2**bits) - 1
    )
  end

  module_function :range_from_bits
end
