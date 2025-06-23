# UnixSocks 🧦🧦

## Description

A Ruby library for handling Unix socket-based communication.

## Features

- **Message Handling**: Simplify sending and receiving messages over Unix sockets.
- **Dynamic Method Access**: Access message body values using method names (e.g., `message.key`).
- **Background Processing**: Run the server in a background thread to avoid blocking main execution.
- **Robust Error Handling**: Gracefully handle socket disconnections and JSON parsing errors.

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

server = UnixSocks::Server.new(socket_name: 'my_socket')

# Run the server in the background to avoid blocking
thread = server.receive_in_background(force: true) do |message|
  puts "Received message: #{message.inspect}"
end

thread.join
```

### 2. Sending Messages

Transmit messages to connected clients:

```ruby
client = UnixSocks::Server.new(socket_name: 'my_socket')

# Prepare your message
message = { status: 'success', data: [1, 2, 3] }

# Send the message
client.transmit(message)
```

### 3. Responding to Messages

Handle incoming messages and send responses:

```ruby
require 'unix_socks'

server = UnixSocks::Server.new(socket_name: 'my_socket')

def handle_message(message)
  # Access message body values using method names
  puts "Received status: #{message.status}"
  
  # Send a response
  message.respond({ status: 'acknowledged' })
end

# Use in your server setup
thread = server.receive_in_background(force: true) do |message|
  handle_message(message)
end

thread.join
```

And in the client:
```ruby
client = UnixSocks::Server.new(socket_name: 'my_socket')

# Prepare your message
message = { status: 'success', data: [1, 2, 3] }

# Send the message
response = client.transmit_with_response(message)

# Receive the response
puts "Received server response status: #{response.status}"
```

### 4. Message Object Features

- **Dynamic Access**: Methods like `message.status` automatically map to the message body.
- **Disconnect Handling**: Safely close socket connections using `disconnect`.
- **Error Resilience**: The `respond` method handles disconnections gracefully.

## Author

[Florian Frank](mailto:flori@ping.de)

## License

[MIT License](./LICENSE)
