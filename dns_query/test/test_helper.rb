# frozen_string_literal: true

require 'minitest/autorun'

# Add the dns_query directory to the load path
$LOAD_PATH.unshift File.expand_path('../', __dir__)

require 'dns_query'
require 'dns_flags'
require 'dns_header'
require 'dns_response'
