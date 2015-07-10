require_relative '../spec_helper'

describe ADAL::MexRequest do
  describe '#initialize' do
    context 'with an invalid endpoint' do
      let(:uri) { 'not a uri' }

      it 'should raise an error' do
        expect { ADAL::MexRequest.new(uri) }.to raise_error(
          URI::InvalidURIError)
      end
    end
  end

  describe '#request' do
    let(:response_body) { 'response body' }
    let(:uri) { 'https://abc.def/' }

    before(:each) do
      @http_request = nil
      expect_any_instance_of(Net::HTTP).to receive(:request) do |_, req|
        @http_request = req
      end.and_return(double(body: response_body))
      expect(ADAL::MexResponse).to receive(:parse)
      ADAL::MexRequest.new(uri).request
    end

    describe 'http request' do
      subject { @http_request }

      it { expect(subject['Content-Type']).to eq 'application/soap+xml' }
      it { expect(subject.path).to eq '/' }
    end
  end
end
