# Manages Unix socket-based communication, providing both server and client
# functionality.
class UnixSocks::DomainSocketServer
  include FileUtils
  include UnixSocks::ServerShared

  # Initializes a new UnixSocks::DomainSocketServer instance.
  #
  # @param socket_name [ String ] The name of the server socket file.
  # @param runtime_dir [ String, nil ] The path to the runtime directory where
  #   the server socket will be created. If not provided, it defaults to the
  #   value returned by #default_runtime_dir.
  def initialize(socket_name:, runtime_dir: default_runtime_dir)
    @socket_name, @runtime_dir = socket_name, runtime_dir
  end

  # Returns the URL representation of the server socket configuration.
  #
  # This method constructs and returns a URL string in the format "unix://path"
  # that represents the Unix socket server's file path
  # configuration.
  #
  # @return [ String ] A URL string in the format "unix://path"
  def to_url
    "unix://#{server_socket_path}"
  end

  # Returns the default runtime directory path based on the XDG_RUNTIME_DIR
  # environment variable.
  #
  # If the XDG_RUNTIME_DIR environment variable is set, its value is used as
  # the runtime directory path. Otherwise, the default path '~/.local/run' is
  # used.
  #
  # @return [ String ] The default runtime directory path.
  def default_runtime_dir
    self.class.default_runtime_dir
  end

  # Returns the default runtime directory path based on the XDG_RUNTIME_DIR
  # environment variable.
  #
  # If the XDG_RUNTIME_DIR environment variable is set, its value is used as
  # the runtime directory path.
  # Otherwise, the default path '~/.local/run' is returned.
  #
  # @return [ String ] The default runtime directory path.
  def self.default_runtime_dir
    File.expand_path(ENV.fetch('XDG_RUNTIME_DIR',  '~/.local/run'))
  end

  # Returns the path to the server socket file.
  #
  # This method constructs the full path to the server socket by joining the
  # runtime directory and the socket name.
  #
  # @return [ String ] The path to the server socket file.
  def server_socket_path
    File.expand_path(File.join(@runtime_dir, @socket_name))
  end

  # The transmit method sends a message over the Unix socket connection
  #
  # This method prepares a message by converting it to JSON format, establishes
  # a connection to the server socket using UNIXSocket.new, writes the
  # prepared message to the socket, and then returns the created socket
  #
  # @param message [ Object ] The message to be sent over the Unix socket
  # @param close [ TrueClass, FalseClass ] Whether to close the socket after sending
  #
  # @return [ UNIXSocket ] The socket connection that was used to transmit the message
  def transmit(message, close: false)
    mkdir_p @runtime_dir
    socket = UNIXSocket.new(server_socket_path)
    socket.puts JSON(message)
    socket
  ensure
    close and socket.close
  end

  # Receives messages from clients connected to the server socket.
  #
  # This method establishes a connection to the server socket and listens for incoming
  # messages. When a message is received, it is parsed as JSON and converted into a
  # UnixSocks::Message object. The block provided to this method is then called with
  # the message object as an argument.
  #
  # If the `force` parameter is set to true, any existing server socket file will be
  # overwritten without raising an error.
  #
  # @param force [ Boolean ] Whether to overwrite any existing server socket file.
  # @yield [ UnixSocks::Message ] The received message.
  def receive(force: false, &block)
    mkdir_p @runtime_dir
    if !force && socket_path_exist?
      raise UnixSocks::ServerError.build(
        Errno::EEXIST, "Path already exists #{server_socket_path.inspect}"
      )
    end
    Socket.unix_server_loop(server_socket_path) do |socket, client_addrinfo|
      message = pop_message(socket) and block.(message)
    end
  end

  # Runs the message receiver in a background thread to prevent blocking.
  #
  # This method starts a new thread that continuously listens for incoming
  # messages from connected clients. The server socket is created in the
  # background, allowing the main execution flow to continue without
  # waiting for messages.
  #
  # @param force [Boolean] Whether to overwrite any existing server socket file
  # @yield [UnixSocks::Message] The received message
  #
  # @return [Thread] The background thread running the receiver
  def receive_in_background(force: false, &block)
    if !force && socket_path_exist?
      raise UnixSocks::ServerError.build(
        Errno::EEXIST, "Path already exists #{server_socket_path.inspect}"
      )
    end
    Thread.new do
      receive(force:, &block)
    rescue Errno::ENOENT
    ensure
      at_exit { remove_socket_path }
    end
  end

  # Checks if the server socket file exists.
  #
  # @return [ Boolean ] True if the socket file exists, false otherwise.
  def socket_path_exist?
    File.exist?(server_socket_path)
  end

  # Safely removes the server socket file from the filesystem.
  def remove_socket_path
    FileUtils.rm_f server_socket_path
  end
end
