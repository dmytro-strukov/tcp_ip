# frozen_string_literal: true

require_relative 'dns_flags'
require_relative 'dns_header'
require_relative 'dns_response'
require_relative 'dns_constants'
require 'socket'

module DNSQuery
  include DNSConstants

  def make(qname, qclass = CLASSES[:IN], qtype = TYPES[:A])
    flags  = DNSFlags.make
    header = DNSHeader.make(flags)

    question = encode_domain(qname) + [qtype, qclass].pack('nn')
    header + question
  end

  def query(domain, dns_server = '8.8.8.8', port = 53, type = :A)
    socket = UDPSocket.new
    query = make(domain, CLASSES[:IN], TYPES[type])

    socket.send(query, 0, dns_server, port)
    response, = socket.recvfrom(512)

    DNSResponse.parse(response)
  end

  def encode_domain(domain)
    domain
      .split('.')
      .map { |x| x.length.chr + x }
      .join + "\0"
  end

  def print_response(response)
    puts 'DNS Response:'
    puts 'Header:'
    puts "  ID: #{response[:header][:id]}"
    puts "  Flags: #{response[:header][:flags].inspect}"
    puts "  Questions: #{response[:header][:questions]}"
    puts "  Answers: #{response[:header][:answers]}"
    puts "  Authorities: #{response[:header][:authorities]}"
    puts "  Additionals: #{response[:header][:additionals]}"

    puts "\nQuestions:"
    response[:questions].each do |q|
      puts "  #{q[:name]} (Type: #{q[:type]}, Class: #{q[:class]})"
    end

    puts "\nAnswers:"
    response[:answers].each do |a|
      puts "  #{a[:name]} (Type: #{a[:type]}, Class: #{a[:class]}, TTL: #{a[:ttl]})"
      puts "    Data: #{a[:rdata]}"
    end
  end

  module_function :make, :query, :encode_domain, :print_response
end

# If the script is run directly (not required as a module)
if __FILE__ == $PROGRAM_NAME
  domain = ARGV[0] || 'example.com'
  type = ARGV[1]&.upcase&.to_sym || :A

  unless DNSConstants::TYPES.key?(type)
    puts "Invalid record type. Available types: #{DNSConstants::TYPES.keys.join(', ')}"
    exit 1
  end

  response = DNSQuery.query(domain, '8.8.8.8', 53, type)
  DNSQuery.print_response(response)
end
