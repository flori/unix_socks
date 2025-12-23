require 'spec_helper'

describe 'UnixSocks::Server Interface' do
  shared_examples 'sufficient interface' do
    it 'supports transmit' do
      expect(described_class).to be_method_defined :transmit
    end

    it 'supports transmit_with_response' do
      expect(described_class).to be_method_defined :transmit_with_response
    end

    it 'supports receive' do
      expect(described_class).to be_method_defined :receive
    end

    it 'supports receive_in_background' do
      expect(described_class).to be_method_defined :receive_in_background
    end

    it 'supports to_uri' do
      expect(described_class).to be_method_defined :to_url
    end
  end

  context UnixSocks::DomainSocketServer do
    it_behaves_like 'sufficient interface'
  end

  context UnixSocks::TCPSocketServer do
    it_behaves_like 'sufficient interface'
  end
end
