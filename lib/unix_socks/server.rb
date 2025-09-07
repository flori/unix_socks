# Manages Unix socket-based communication, providing both server and client
# functionality.
class UnixSocks::Server
  include FileUtils

  # Initializes a new UnixSocks::Server instance.
  #
  # @param socket_name [ String ] The name of the server socket file.
  # @param runtime_dir [ String, nil ] The path to the runtime directory where
  #   the server socket will be created. If not provided, it defaults to the
  #   value returned by #default_runtime_dir.
  def initialize(socket_name:, runtime_dir: default_runtime_dir)
    @socket_name, @runtime_dir = socket_name, runtime_dir
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

  # The transmit method sends a message over the Unix socket connection.
  #
  # It first prepares the message by converting it to JSON format, and then
  # establishes a connection to the server socket using UNIXSocket.new.
  #
  # Finally, it writes the prepared message to the socket using socket.puts,
  # ensuring that the socket is properly closed after use.
  #
  # @param message [ Message ] The message to be sent over the Unix socket.
  def transmit(message)
    mkdir_p @runtime_dir
    socket = UNIXSocket.new(server_socket_path)
    socket.puts JSON(message)
    socket
  end

  # Sends a message and returns the parsed JSON response.
  #
  # @param message [Object] The message to be sent as JSON.
  # @return [Hash, nil] The parsed JSON response or nil if parsing fails.
  def transmit_with_response(message)
    socket = transmit(message)
    parse_json_message(socket.gets, socket)
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
      raise Errno::EEXIST, "Path already exists #{server_socket_path.inspect}"
    end
    Socket.unix_server_loop(server_socket_path) do |socket, client_addrinfo|
      message = pop_message(socket) and block.(message)
    end
  end

  # The receive_in_background method runs the server socket listener in a
  # separate thread, allowing it to continue executing without blocking the
  # main program flow.
  #
  # @param force [ Boolean ] Whether to overwrite any existing server socket file.
  # @yield [ UnixSocks::Message ] The received message.
  def receive_in_background(force: false, &block)
    Thread.new do
      receive(force:, &block)
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

  private

  def pop_message(socket)
    parse_json_message(socket.gets, socket)
  end

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
