require_relative '../spec_helper'

describe ADAL::WSTrustRequest do
  subject { ADAL::WSTrustRequest.new(uri) }

  describe '#initialize' do
    context 'with an invalid URI' do
      let(:uri) { 'not a uri' }

      it 'should raise InvalidURIError' do
        expect do
          ADAL::WSTrustRequest.new(uri)
        end.to raise_error(URI::InvalidURIError)
      end
    end
  end

  describe '#request' do
    let(:uri) { 'https://microsoft.com/' }

    it 'parses the body as an ADAL::WSTrustResponse' do
      mex_response_body = 'mex body'
      expect_any_instance_of(Net::HTTP).to receive(:request).once
        .and_return(double(body: mex_response_body))
      expect(ADAL::WSTrustResponse).to receive(:parse).with(mex_response_body)
      subject.request('some user', 'some password')
    end
  end
end
