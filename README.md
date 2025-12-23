# UnixSocks 🧦🧦

## Description

A Ruby library for handling inter-process communication via Unix sockets and
TCP sockets.

## Features

- **Dual Socket Support**: Handle both Unix domain sockets and TCP sockets with
  a consistent API
- **Message Handling**: Simplify sending and receiving messages over sockets
- **Dynamic Method Access**: Access message body values using method names
  (e.g., `message.key`)
- **Background Processing**: Run servers in background threads to avoid
  blocking main execution
- **Robust Error Handling**: Gracefully handle socket disconnections and JSON
  parsing errors
- **URL Interface**: Servers can be represented as URL strings for easy
  configuration and discovery

## Installation

Add this gem to your Gemfile:

```ruby
gem 'unix_socks'
```

And install it using Bundler:

```bash
bundle install
```

Or install the gem directly:

```bash
gem install unix_socks
```

## Usage

### 1. Server Setup

Create a server instance and start listening for connections:

```ruby
require 'unix_socks'

# For Unix sockets
server = UnixSocks::DomainSocketServer.new(socket_name: 'my_socket')

# For TCP sockets  
server = UnixSocks::TCPSocketServer.new(hostname: 'localhost', port: 8080)

# Run the server in the background to avoid blocking
thread = server.receive_in_background do |message|
  puts "Received message: #{message.inspect}"
end

thread.join
```

### 2. Sending Messages

Transmit messages to connected clients:

```ruby
# For Unix sockets
client = UnixSocks::DomainSocketServer.new(socket_name: 'my_socket')

# For TCP sockets
client = UnixSocks::TCPSocketServer.new(hostname: 'localhost', port: 8080)

# Prepare your message
message = { status: 'success', data: [1, 2, 3] }

# Send the message
client.transmit(message)
```

### 3. Responding to Messages

Handle incoming messages and send responses:

```ruby
require 'unix_socks'

# For Unix sockets
server = UnixSocks::DomainSocketServer.new(socket_name: 'my_socket')

# For TCP sockets
server = UnixSocks::TCPSocketServer.new(hostname: 'localhost', port: 8080)

def handle_message(message)
  # Access message body values using method names
  puts "Received status: #{message.status}"
  
  # Send a response
  message.respond({ status: 'acknowledged' })
end

# Use in your server setup
thread = server.receive_in_background do |message|
  handle_message(message)
end

thread.join
```

And in the client:
```ruby
# For Unix sockets
client = UnixSocks::DomainSocketServer.new(socket_name: 'my_socket')

# For TCP sockets
client = UnixSocks::TCPSocketServer.new(hostname: 'localhost', port: 8080)

# Prepare your message
message = { status: 'success', data: [1, 2, 3] }

# Send the message and get a response
response = client.transmit_with_response(message)

# Receive the response
puts "Received server response status: #{response.status}"
```

### 4. Force Parameter Behavior

The `force` parameter is only applicable to Unix domain socket servers and
controls whether existing socket files should be overwritten:

- **Unix Socket Servers**: When `force: true` is specified, existing socket
  files will be overwritten without raising an error. Otherwise a
  `UnixSocks::ServerError` is raised.
- **TCP Socket Servers**: The `force` parameter is accepted for interface
  compatibility but has no effect since TCP sockets don't use filesystem-based
  socket files

```ruby
# Unix socket - force parameter works
server = UnixSocks::DomainSocketServer.new(socket_name: 'my.sock')
server.receive(force: true)  # Overwrites existing socket file if it exists

# TCP socket - force parameter is ignored
server = UnixSocks::TCPSocketServer.new(hostname: 'localhost', port: 8080)
server.receive(force: true)  # Parameter has no effect
```

### 5. Server URL Interface

Both server types support URL representation for easy configuration and discovery:

```ruby
# Unix socket server URL
unix_server = UnixSocks::DomainSocketServer.new(socket_name: 'my.sock')
unix_url = unix_server.to_url  # => "unix:///full/path/to/my.sock"

# TCP socket server URL  
tcp_server = UnixSocks::TCPSocketServer.new(hostname: 'localhost', port: 8080)
tcp_url = tcp_server.to_url  # => "tcp://localhost:8080"

# Use URLs for configuration
server = UnixSocks.from_url(tcp_url)
```

### 6. Message Object Features

- **Dynamic Access**: Methods like `message.status` automatically map to the
  message body
- **Disconnect Handling**: Safely close socket connections using `disconnect`
- **Error Resilience**: The `respond` method handles disconnections gracefully
- **Consistent Error Handling**: All server errors are wrapped in
  `UnixSocks::ServerError`

## Author

[Florian Frank](mailto:flori@ping.de)

## License

[MIT License](LICENSE)
