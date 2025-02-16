# frozen_string_literal: true

require_relative 'dns_header'
require_relative 'dns_constants'

module DNSResponse
  include DNSConstants

  def parse(bytes)
    query_id, flags, qd_count, an_count, ns_count, ar_count = DNSHeader.parse(bytes.byteslice(0, 12))

    offset = 12
    questions = []

    qd_count.times do
      name, new_offset = decode_name(bytes, offset)
      qtype, qclass = bytes[new_offset, 4].unpack('nn')
      questions << {
        name: name,
        type: get_type_name(qtype),
        class: get_class_name(qclass)
      }
      offset = new_offset + 4
    end

    answers = []

    an_count.times do
      name, new_offset = decode_name(bytes, offset)
      type, klass, ttl, rdlength = bytes[new_offset, 10].unpack('nnNn')
      rdata_offset = new_offset + 10

      rdata = case type
              when TYPES[:A]
                bytes[rdata_offset, rdlength].unpack('CCCC').join('.')
              when TYPES[:CNAME]
                decode_name(bytes, rdata_offset).first
              when TYPES[:NS]
                decode_name(bytes, rdata_offset).first
              when TYPES[:MX]
                preference = bytes[rdata_offset, 2].unpack1('n')
                exchange, = decode_name(bytes, rdata_offset + 2)
                "#{preference} #{exchange}"
              else
                bytes[rdata_offset, rdlength].unpack1('H*')
              end

      answers << {
        name: name,
        type: get_type_name(type),
        class: get_class_name(klass),
        ttl: ttl,
        rdata: rdata
      }

      offset = rdata_offset + rdlength
    end

    {
      header: {
        id: query_id,
        flags: flags,
        questions: qd_count,
        answers: an_count,
        authorities: ns_count,
        additionals: ar_count
      },
      questions: questions,
      answers: answers
    }
  end

  def decode_name(bytes, offset)
    name_parts = []
    current_offset = offset

    loop do
      length = bytes[current_offset].ord

      if (length & 0xC0) == 0xC0
        pointer = ((length & 0x3F) << 8) | bytes[current_offset + 1].ord
        pointed_name, = decode_name(bytes, pointer)
        name_parts << pointed_name
        current_offset += 2
        break
      elsif length.zero?
        current_offset += 1
        break
      else
        name_parts << bytes[current_offset + 1, length]
        current_offset += length + 1
      end
    end

    [name_parts.join('.'), current_offset]
  end

  def get_type_name(type)
    TYPES.invert[type] || type.to_s
  end

  def get_class_name(klass)
    CLASSES.invert[klass] || klass.to_s
  end

  module_function :parse, :decode_name, :get_type_name, :get_class_name
end
