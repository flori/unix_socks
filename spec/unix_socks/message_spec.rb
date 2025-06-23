require 'spec_helper'

describe UnixSocks::Message do
  let(:socket) { instance_double(Socket) }
  let(:key) { 'value' }

  subject { described_class[key:, socket:] }

  describe '#initialize' do
    it 'sets the body and socket' do
      expect(subject).to be_a described_class
      expect(subject.key).to eq 'value'
      expect(subject.socket).to eq(socket)
    end
  end

  describe '#disconnect' do
    it 'closes the socket' do
      expect(socket).to receive(:close)
      subject.disconnect
    end
  end

  describe '#respond' do
    let(:answer) { { response: 'ok' } }

    it 'sends a JSON response over the socket' do
      expected_json = answer.to_json
      expect(socket).to receive(:puts).with(expected_json)
      subject.respond(answer)
    end

    it 'handles EPIPE errors gracefully' do
      allow(socket).to receive(:puts).and_raise(Errno::EPIPE)
      expect { subject.respond(answer) }.not_to raise_error
    end
  end
end
