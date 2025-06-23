require 'spec_helper'
require 'tins/xt/expose'

describe UnixSocks::Server do
  let(:socket_name) { 'test_socket' }
  let(:runtime_dir) { './tmp' }
  let(:server) { UnixSocks::Server.new(socket_name: socket_name, runtime_dir: runtime_dir).expose }

  describe '#initialize' do
    it 'sets the socket name and runtime directory' do
      expect(server.instance_variable_get(:@socket_name)).to eq(socket_name)
      expect(server.instance_variable_get(:@runtime_dir)).to eq(runtime_dir)
    end
  end

  describe '#default_runtime_dir' do
    it 'returns the correct default runtime directory' do
      ENV['XDG_RUNTIME_DIR'] = nil
      expect(server.default_runtime_dir).to eq(File.expand_path('~/.local/run'))

      ENV['XDG_RUNTIME_DIR'] = '/tmp/runtime'
      expect(server.default_runtime_dir).to eq('/tmp/runtime')
    end
  end

  describe '#server_socket_path' do
    it 'returns the correct socket path' do
      expected_path = File.expand_path(File.join(runtime_dir, socket_name))
      expect(server.server_socket_path).to eq(expected_path)
    end
  end

  describe '#transmit' do
    let(:message) { { test: 'message' } }

    it 'sends a message over the Unix socket' do
      expect(server).to receive(:mkdir_p).with(runtime_dir)
      expect(UNIXSocket).to receive(:new).with(server.server_socket_path).
        and_return(double('socket', puts: nil, close: nil))
      server.transmit(message)
    end
  end

  describe '#transmit_with_response' do
    let(:message) { { test: 'message' } }

    it 'parses a valid JSON response' do
      allow(server).to receive(:mkdir_p)
      mock_socket = double('socket', puts: nil, gets: '{"status": "success"}')
      expect(UNIXSocket).to receive(:new).and_return(mock_socket)

      response = server.transmit_with_response(message)
      expect(response).to be_a UnixSocks::Message
      expect(response.status).to eq 'success'
    end

    it 'handles JSON parsing errors' do
      allow(server).to receive(:mkdir_p)
      mock_socket = double('socket', puts: nil, gets: 'invalid_json')
      expect(server).to receive(:warn).
        with(/Caught JSON::ParserError: unexpected character: 'invalid_json'/)
      expect(UNIXSocket).to receive(:new).and_return(mock_socket)

      response = server.transmit_with_response(message)
      expect(response).to be nil
    end

    it 'handles empty responses' do
      allow(server).to receive(:mkdir_p)
      mock_socket = double('socket', puts: nil, gets: '')
      expect(UNIXSocket).to receive(:new).and_return(mock_socket)

      response = server.transmit_with_response(message)
      expect(response).to be nil
    end
  end

  describe '#receive' do
    it 'raises an error if the socket already exists and force is false' do
      allow(server).to receive(:socket_path_exist?).and_return(true)
      expect { server.receive(force: false) }.to\
        raise_error(Errno::EEXIST, /Path already exists/)
    end

    it 'does not raise an error if force is true' do
      allow(server).to receive(:socket_path_exist?).and_return(true)
      expect(Socket).to receive(:unix_server_loop).with(server.server_socket_path)
      server.receive(force: true)
    end
  end

  describe 'pop_message' do
    it 'parses a valid JSON message' do
      mock_socket = double('socket')
      allow(mock_socket).to receive(:gets).and_return('{"test": "message"}')

      message = server.pop_message(mock_socket)
      expect(message).to be_a(UnixSocks::Message)
      expect(message.test).to eq 'message'
    end

    it 'handles a JSON parsing error' do
      mock_socket = double('socket')
      allow(mock_socket).to receive(:gets).and_return('invalid_json')
      expect(server).to receive(:warn).
        with(/Caught JSON::ParserError: unexpected character: 'invalid_json'/)
      expect(server.pop_message(mock_socket)).to be nil
    end
  end

  describe '#receive_in_background' do
    it 'runs the receiver in a background thread' do
      expect(Thread).to receive(:new).and_yield
      expect(FileUtils).to receive(:rm_f).with(server.server_socket_path)
      expect(server).to receive(:receive).with(force: true)

      server.receive_in_background(force: true)
    end
  end

  describe '#socket_path_exist?' do
    it 'returns false if the socket file does not exist' do
      FileUtils.rm_f(server.server_socket_path)
      expect(server.socket_path_exist?).to be false
    end

    it 'returns true if the socket file does exist' do
      FileUtils.touch(server.server_socket_path)
      expect(server.socket_path_exist?).to be true
    end
  end

  describe '#remove_socket_path' do
    it 'removes the socket file' do
      expect(FileUtils).to receive(:rm_f).with(server.server_socket_path)

      server.remove_socket_path
    end
  end
end
