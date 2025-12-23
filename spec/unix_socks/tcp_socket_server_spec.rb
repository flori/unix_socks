require 'spec_helper'
require 'tins/xt/expose'

describe UnixSocks::TCPSocketServer do
  let(:server) { described_class.new(hostname: 'localhost', port: 1234).expose }

  describe '#initialize' do
    it 'sets the socket name and runtime directory' do
      expect(server.instance_variable_get(:@hostname)).to eq('localhost')
      expect(server.instance_variable_get(:@port)).to eq(1234)
    end
  end

  describe '#transmit' do
    let(:message) { { test: 'message' } }

    it 'sends a message over the Unix socket' do
      expect(TCPSocket).to receive(:new).with(server.hostname, server.port).
        and_return(double('socket', puts: nil))
      server.transmit(message)
    end

    it 'sends a message over the Unix socket and close' do
      socket = double('socket', puts: nil)
      expect(TCPSocket).to receive(:new).with(server.hostname, server.port).
        and_return(socket)
      expect(socket).to receive(:close)
      server.transmit(message, close: true)
    end
  end

  describe '#transmit_with_response' do
    let(:message) { { test: 'message' } }

    it 'parses a valid JSON response' do
      allow(server).to receive(:mkdir_p)
      socket = double(
        'socket',
        puts: nil,
        gets: '{"status": "success"}',
        close: true
      )
      expect(TCPSocket).to receive(:new).and_return(socket)

      response = server.transmit_with_response(message)
      expect(response).to be_a UnixSocks::Message
      expect(response.status).to eq 'success'
    end

    it 'handles JSON parsing errors' do
      allow(server).to receive(:mkdir_p)
      socket = double(
        'socket',
        puts: nil,
        gets: 'invalid_json',
        close: true
      )
      expect(server).to receive(:warn).
        with(/Caught JSON::ParserError: unexpected character: 'invalid_json'/)
      expect(TCPSocket).to receive(:new).and_return(socket)

      response = server.transmit_with_response(message)
      expect(response).to be nil
    end

    it 'handles empty responses' do
      allow(server).to receive(:mkdir_p)
      socket = double(
        'socket',
        puts: nil,
        gets: '',
        close: true
      )
      expect(TCPSocket).to receive(:new).and_return(socket)

      response = server.transmit_with_response(message)
      expect(response).to be nil
    end
  end

  describe '#receive' do
    it 'does bind to hostname:port' do
      expect(Addrinfo).to receive(:tcp).with(server.hostname, server.port).
        and_return(double(bind: true))
      server.receive
    end

    it 'raises UnixSocks::ServerError if already bound' do
      socket = double('socket')
      expect(Addrinfo).to receive(:tcp).with(server.hostname, server.port).
        and_return(socket)
      expect(socket).to receive(:bind).and_raise Errno::EADDRINUSE
      expect { server.receive }.to raise_error(UnixSocks::ServerError)
    end
  end

  describe 'pop_message' do
    it 'parses a valid JSON message' do
      socket = double('socket')
      allow(socket).to receive(:gets).and_return('{"test": "message"}')

      message = server.pop_message(socket)
      expect(message).to be_a(UnixSocks::Message)
      expect(message.test).to eq 'message'
    end

    it 'handles a JSON parsing error' do
      socket = double('socket')
      allow(socket).to receive(:gets).and_return('invalid_json')
      expect(server).to receive(:warn).
        with(/Caught JSON::ParserError: unexpected character: 'invalid_json'/)
      expect(server.pop_message(socket)).to be nil
    end
  end

  describe '#receive_in_background' do
    it 'runs the receiver in a background thread' do
      expect(Thread).to receive(:new).and_yield.and_return(double(join: true))
      expect(server).to receive(:receive)

      server.receive_in_background.join
    end

    it 'it raises UnixSocks::ServerError if socket already exists' do
      expect(server).to receive(:receive).and_raise(Errno::EADDRINUSE)
      expect {
        server.receive_in_background.join
      }.to raise_error(UnixSocks::ServerError)
    end
  end

  describe '#to_uri' do
    it 'displays address' do
      expect(server.to_url).to eq 'tcp://localhost:1234'
    end
  end
end
