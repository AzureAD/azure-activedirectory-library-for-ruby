require_relative '../spec_helper'

MEX_FIXTURES = File.expand_path('../../fixtures/mex', __FILE__)

describe ADAL::MexResponse do
  describe '::parse' do
    let(:response) { File.read(File.expand_path(file_name, MEX_FIXTURES)) }

    context 'with a successful response' do
      let(:file_name) { 'microsoft.xml' }
      let(:wstrust_url) { 'https://corp.sts.microsoft.com/adfs/services/trust/13/usernamemixed' }

      it 'should not raise an error' do
        expect { ADAL::MexResponse.parse(response) }.to_not raise_error
      end

      it 'should parse the WS-Trust url' do
        expect(ADAL::MexResponse.parse(response).wstrust_url.to_s)
          .to eq(wstrust_url)
      end
    end

    context 'with a malformed response' do
      let(:file_name) { 'malformed.xml' }

      it 'should throw an error' do
        expect { ADAL::MexResponse.parse(response) }.to raise_error(
          ADAL::MexResponse::MexError)
      end
    end

    context 'with insecure address' do
      let(:file_name) { 'insecureaddress.xml' }

      it 'should throw an error' do
        expect { ADAL::MexResponse.parse(response) }.to raise_error(
          ArgumentError)
      end
    end
  end
end
