# Provides TCP socket-based communication for inter-process messaging.
#
# This class enables sending and receiving messages over TCP connections,
# supporting both client and server functionality for network-based
# communication.
#
# @example
#   server = UnixSocks::TCPSocketServer.new(hostname: 'localhost', port: 8080)
#   server.receive { |message| puts message.inspect }
#   server.transmit({ message: 'hello' })
class UnixSocks::TCPSocketServer
  include UnixSocks::ServerShared

  # Initializes a new UnixSocks::TCPSocketServer instance.
  #
  # Sets up the server with the specified hostname and port for TCP
  # communication.
  #
  # @param hostname [ String ] The hostname to bind to, defaults to 'localhost'
  # @param port [ Integer ] The port number to bind to
  def initialize(hostname: 'localhost', port:)
    @hostname, @port = hostname, port
  end

  # Returns the hostname associated with this TCP socket server instance.
  #
  # @return [ String ] The hostname that the server binds to for TCP communication.
  attr_reader :hostname

  # Returns the port number associated with this TCP socket server instance.
  #
  # @return [ Integer ] The port number that the server binds to for TCP communication.
  attr_reader :port

  # Returns the URL representation of the TCP socket server configuration.
  #
  # This method constructs and returns a URL string in the format
  # "tcp://hostname:port" that represents the TCP socket server's address and
  # port configuration.
  #
  # @return [ String ] A URL string in the format "tcp://hostname:port"
  def to_url
    "tcp://#@hostname:#@port"
  end

  # Sends a message over a TCP connection to the configured hostname and port.
  #
  # This method establishes a TCP socket connection to the specified hostname
  # and port, serializes the provided message to JSON format, and writes it to
  # the socket. The socket connection is returned after the message is sent.
  #
  # @param message [Object] The message to be sent, which will be converted to JSON
  # @param close [TrueClass, FalseClass] Whether to close the socket after sending
  #
  # @return [TCPSocket] The socket connection that was used to transmit the message
  def transmit(message, close: false)
    socket = TCPSocket.new(@hostname, @port)
    socket.puts JSON(message)
    socket
  ensure
    close and socket.close
  end

  # Receives messages from clients connected to the TCP socket.
  #
  # This method binds to the configured hostname and port, listens for incoming
  # connections, and processes messages from connected clients. It accepts a
  # single connection at a time and handles each message by parsing it from
  # JSON and yielding it to the provided block. The socket connection is closed
  # after processing each message.
  #
  # @param force [ nil ] This parameter is accepted for interface compatibility
  #   but is unused in the TCP implementation.
  # @yield [ UnixSocks::Message ] The received message parsed from JSON.
  #
  # @raise [ Errno::EADDRINUSE ] If the address is already in use.
  def receive(force: nil, &block)
    Addrinfo.tcp(@hostname, @port).bind do |server|
      server.listen(1)
      loop do
        socket, = server.accept
        message = pop_message(socket) and block.(message)
        socket.close
      end
    end
  rescue Errno::EADDRINUSE => e
    raise UnixSocks::ServerError.mark(e)
  end

  # Runs the message receiver in a background thread to prevent blocking.
  #
  # This method starts a new thread that continuously listens for incoming
  # messages from connected clients. The server socket is created in the
  # background, allowing the main execution flow to continue without
  # waiting for messages.
  #
  # @param force [ nil ] This parameter is accepted for interface compatibility
  #   but is unused in the TCP implementation.
  # @yield [UnixSocks::Message] The received message
  #
  # @return [Thread] The background thread running the receiver
  def receive_in_background(force: nil, &block)
    Thread.new do
      receive(&block)
    rescue Errno::EADDRINUSE => e
      raise UnixSocks::ServerError.mark(e)
    end
  end
end
