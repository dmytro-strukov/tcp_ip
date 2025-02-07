require 'socket'
require 'pry'
require_relative 'dns_query/dns_query'
require_relative 'dns_query/dns_response'

# Google Public DNS
DNS_SERVER = '8.8.8.8'
DNS_PORT = 53

# Example usage
query = DNSQuery.make('example.com')
p query

# Uncomment to send actual DNS query
# socket = UDPSocket.new
# socket.send(query, 0, DNS_SERVER, DNS_PORT)
# response = socket.recvfrom(512)
# p DNSResponse.parse(response.first) 