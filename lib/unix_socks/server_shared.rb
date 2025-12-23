# Shared server functionality for UnixSocks implementations
#
# This module provides common methods for transmitting messages and parsing
# JSON responses that are used by both Unix domain socket and TCP socket
# server implementations.
module UnixSocks::ServerShared
  # Sends a message and returns the parsed JSON response.
  #
  # @param message [Object] The message to be sent as JSON.
  # @return [Hash, nil] The parsed JSON response or nil if parsing fails.
  def transmit_with_response(message, close: true)
    socket = transmit(message, close: false)
    parse_json_message(socket.gets, socket)
  ensure
    close and socket.close
  end

  # Converts the server's URL representation into a URI object.
  #
  # This method takes the URL string returned by #to_url and parses it into
  # a URI object for convenient access to the server's address components.
  #
  # @return [ URI ] A URI object representing the server's address configuration.
  def to_uri
    URI.parse(to_url)
  end

  private

  # Parses a JSON message from the socket and associates it with the socket
  # connection
  #
  # This method retrieves a line of data from the socket, strips whitespace,
  # and attempts to parse it as JSON. If successful, it creates a
  # UnixSocks::Message object with the parsed data and assigns the socket
  # connection to the message. If parsing fails, it logs a warning and
  # returns nil.
  #
  # @param socket [ Socket ] the socket connection to read from
  #
  # @return [ UnixSocks::Message, nil ] the parsed message object or nil if
  #   parsing fails
  def pop_message(socket)
    parse_json_message(socket.gets, socket)
  end

  # Parses a JSON message from the given data and associates it with the
  # provided socket connection.
  #
  # This method processes the input data by stripping whitespace and attempting
  # to parse it as JSON. If parsing is successful, it creates a
  # UnixSocks::Message object with the parsed data and assigns the socket
  # connection to the message. In case of a JSON parsing error, it
  # logs a warning and returns nil.
  #
  # @param data [ String ] The raw data string to be parsed as JSON.
  # @param socket [ Socket ] The socket connection associated with the message.
  #
  # @return [ UnixSocks::Message, nil ] The parsed message object or nil if
  #   parsing fails.
  def parse_json_message(data, socket)
    data = data.strip
    data.empty? and return nil
    obj = JSON.parse(data, object_class: UnixSocks::Message)
    obj.socket = socket
    obj
  rescue JSON::ParserError => e
    warn "Caught #{e.class}: #{e} for #{data[0, 512].inspect}"
  end
end
