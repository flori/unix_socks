require 'json'
require 'fileutils'
require 'socket'
require 'uri'
require 'tins'

# Provides classes for handling inter-process communication via Unix 🧦🧦.
# Supports dynamic message handling, background processing, and robust error
# management.
module UnixSocks
  # Creates a server instance from a URL string.
  #
  # This method parses a URL and constructs the appropriate server instance
  # based on the scheme. For 'unix' URLs, it creates a DomainSocketServer,
  # and for 'tcp' URLs, it creates a TCPSocketServer.
  #
  # @param url [String, URI] The URL string or URI object representing the
  #   server configuration
  #
  # @return [UnixSocks::DomainSocketServer, UnixSocks::TCPSocketServer] The
  #   constructed server instance
  #
  # @raise [ArgumentError] If the URL scheme is not 'unix' or 'tcp'
  def self.from_url(url)
    uri = url.is_a?(URI) ? url : URI.parse(url.to_s)
    case uri.scheme
    when 'unix'
      DomainSocketServer.new(
        socket_name: File.basename(uri.path),
        runtime_dir: File.dirname(uri.path)
      )
    when 'tcp'
      TCPSocketServer.new(
        hostname: uri.host,
        port:     uri.port
      )
    else
      raise ArgumentError, "Invalid URL #{url.to_s.inspect} for UnixSocks"
    end
  end
end

require 'unix_socks/version'
require 'unix_socks/server_error'
require 'unix_socks/message'
require 'unix_socks/server_shared'
require 'unix_socks/domain_socket_server'
require 'unix_socks/tcp_socket_server'
