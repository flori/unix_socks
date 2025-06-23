require 'tins/xt/ask_and_send'
require 'json'

# Represents a message sent or received over a Unix socket, extending
# JSON::GenericObject for dynamic access to message attributes.
class UnixSocks::Message < JSON::GenericObject
  # Disconnects the socket connection.
  #
  # Closes the underlying socket, effectively ending the communication session.
  def disconnect
    socket.close
  end

  # The respond method sends a response back to the client over the Unix socket
  # connection.
  #
  # It first converts the provided answer into JSON format, and then writes it
  # to the socket using socket.puts.
  #
  # @param answer [ Object ] The response to be sent back to the client.
  #
  # @return [ UnixSocks::Message ] The current message object.
  def respond(answer)
    answer = answer.ask_and_send(:to_json) or
      raise TypeError, 'needs to be convertibla to JSON'
    socket.puts answer
  rescue Errno::EPIPE
    self
  end
end
