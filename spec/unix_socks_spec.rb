require 'spec_helper'

describe UnixSocks do
  describe '.from_url' do
    context 'with unix URL' do
      it 'creates a DomainSocketServer' do
        server = UnixSocks.from_url('unix:///tmp/my.sock')
        expect(server).to be_a(UnixSocks::DomainSocketServer)
      end

      it 'sets correct socket name and runtime directory' do
        server = UnixSocks.from_url('unix:///tmp/my.sock')
        expect(server.instance_variable_get(:@socket_name)).to eq('my.sock')
        expect(server.instance_variable_get(:@runtime_dir)).to eq('/tmp')
      end

      it 'handles unix URL with different runtime directory' do
        server = UnixSocks.from_url('unix:///var/run/my.sock')
        expect(server.instance_variable_get(:@socket_name)).to eq('my.sock')
        expect(server.instance_variable_get(:@runtime_dir)).to eq('/var/run')
      end

      it 'works with URI objects' do
        uri = URI.parse('unix:///tmp/test.sock')
        server = UnixSocks.from_url(uri)
        expect(server).to be_a(UnixSocks::DomainSocketServer)
        expect(server.instance_variable_get(:@socket_name)).to eq('test.sock')
      end
    end

    context 'with tcp URL' do
      it 'creates a TCPSocketServer' do
        server = UnixSocks.from_url('tcp://localhost:8080')
        expect(server).to be_a(UnixSocks::TCPSocketServer)
      end

      it 'sets correct hostname and port' do
        server = UnixSocks.from_url('tcp://example.com:9000')
        expect(server.instance_variable_get(:@hostname)).to eq('example.com')
        expect(server.instance_variable_get(:@port)).to eq(9000)
      end

      it 'works with default port' do
        server = UnixSocks.from_url('tcp://localhost:80')
        expect(server.instance_variable_get(:@hostname)).to eq('localhost')
        expect(server.instance_variable_get(:@port)).to eq(80)
      end

      it 'works with URI objects' do
        uri = URI.parse('tcp://localhost:8080')
        server = UnixSocks.from_url(uri)
        expect(server).to be_a(UnixSocks::TCPSocketServer)
        expect(server.instance_variable_get(:@hostname)).to eq('localhost')
        expect(server.instance_variable_get(:@port)).to eq(8080)
      end
    end

    context 'with invalid URL' do
      it 'raises ArgumentError for unsupported scheme' do
        expect {
          UnixSocks.from_url('ftp://example.com/file')
        }.to raise_error(ArgumentError, /Invalid URL.*ftp/)
      end

      it 'raises ArgumentError for invalid URL format' do
        expect {
          UnixSocks.from_url('not_a_url')
        }.to raise_error(ArgumentError)
      end
    end

    context 'with edge cases' do
      it 'handles URLs with query parameters' do
        server = UnixSocks.from_url('unix:///tmp/test.sock?param=value')
        expect(server).to be_a(UnixSocks::DomainSocketServer)
        expect(server.instance_variable_get(:@socket_name)).to eq('test.sock')
      end

      it 'handles URLs with fragments' do
        server = UnixSocks.from_url('tcp://localhost:8080#fragment')
        expect(server).to be_a(UnixSocks::TCPSocketServer)
        expect(server.instance_variable_get(:@hostname)).to eq('localhost')
        expect(server.instance_variable_get(:@port)).to eq(8080)
      end
    end
  end

  describe 'integration test' do
    it 'can create and use unix server from URL' do
      server = UnixSocks.from_url('unix:///tmp/test.sock')
      expect(server).to be_a(UnixSocks::DomainSocketServer)
      expect(server.to_url).to match(%r{^unix://.*test\.sock$})
    end

    it 'can create and use tcp server from URL' do
      server = UnixSocks.from_url('tcp://localhost:8080')
      expect(server).to be_a(UnixSocks::TCPSocketServer)
      expect(server.to_url).to eq('tcp://localhost:8080')
    end
  end
end
