# DNS Query Implementation in Ruby

This project implements a DNS query client following the specifications outlined in RFC 1035 (Domain Names - Implementation and Specification). It provides functionality to create and parse DNS messages for querying domain name information.

## Overview

The DNS query implementation includes the following components:

- DNS Message Format handling
- Header section processing
- Question section handling
- Resource Records parsing
- DNS Flags management

## Project Structure

```
dns_query/
├── dns_query.rb       # Main DNS query implementation
├── dns_header.rb      # DNS header section handling
├── dns_flags.rb       # DNS flags implementation
├── dns_response.rb    # DNS response parsing
└── test/             # Test suite
    ├── dns_query_test.rb
    ├── dns_flags_test.rb
    └── test_helper.rb
```

## Features

- DNS message composition according to RFC 1035 specifications
- Support for standard query types (A, AAAA, MX, etc.)
- DNS header and flags manipulation
- Response parsing and interpretation
- Error handling for malformed responses

## Usage

```bash
ruby dns_query.rb <domain> <type of record>

ruby dns_query.rb gogle.com NS
ruby dns_query.rb google.com TXT
```

## Message Format

Following RFC 1035, all DNS messages have the following format:

    +---------------------+
    |        Header      |
    +---------------------+
    |       Question     | 
    +---------------------+
    |        Answer      |
    +---------------------+
    |      Authority     |
    +---------------------+
    |      Additional    |
    +---------------------+

## Installation

1. Clone the repository
2. Ensure Ruby is installed
3. Run the test suite:
   ```
   ruby test/dns_query_test.rb
   ```

## Testing

The project includes a comprehensive test suite covering:
- DNS message formatting
- Query construction
- Response parsing
- Error handling

## Requirements

- Ruby 2.6 or higher

## License

MIT License

## Contributing

1. Fork the repository
2. Create your feature branch
3. Submit a pull request

## References

- [RFC 1035 - Domain Names - Implementation and Specification](https://tools.ietf.org/html/rfc1035)
