#-------------------------------------------------------------------------------
# Copyright (c) 2015 Micorosft Corporation
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#-------------------------------------------------------------------------------

require_relative '../spec_helper'

WSTRUST_FIXTURES = File.expand_path('../../fixtures/wstrust', __FILE__)

describe ADAL::WSTrustResponse do
  describe '::parse' do
    let(:response) { File.read(File.expand_path(file_name, WSTRUST_FIXTURES)) }

    context 'with a successful response' do
      let(:file_name) { 'success.xml' }

      let(:token) do
        File.read(File.expand_path('token.xml', WSTRUST_FIXTURES))
      end

      it 'correctly extracts the token' do
        wstrust_response = ADAL::WSTrustResponse.parse(response)
        expect(wstrust_response.token.strip).to eq(token.strip)
      end

      it 'has the correct grant type' do
        wstrust_response = ADAL::WSTrustResponse.parse(response)
        expect(wstrust_response.grant_type).to eq(
          ADAL::TokenRequest::GrantType::SAML1)
      end
    end

    context 'with an unrecognized token type' do
      let(:file_name) { 'unrecognized_token_type.xml' }

      it 'throws the appropriate error' do
        expect { ADAL::WSTrustResponse.parse(response) }
          .to raise_error(ADAL::WSTrustResponse::UnrecognizedTokenTypeError)
      end
    end

    context 'with a WS-Trust 1.3 response' do
      let(:file_name) { 'wstrust.13.xml' }

      it 'extracts the token' do
        wstrust_response = ADAL::WSTrustResponse.parse(response)
        expect(wstrust_response.token.strip).to_not be nil
      end
    end

    context 'with a WS-Trust 2005 response' do
      let(:file_name) { 'wstrust.2005.xml' }

      it 'extracts the token' do
        wstrust_response = ADAL::WSTrustResponse.parse(response)
        expect(wstrust_response.token.strip).to_not be nil
      end
    end

    context 'with an error response' do
      let(:file_name) { 'error.xml' }

      it 'throws the appropriate error' do
        expect do
          ADAL::WSTrustResponse.parse(response)
        end.to raise_error(ADAL::WSTrustResponse::WSTrustError, /MSIS3127/)
      end
    end

    context 'with invalid namespaces' do
      let(:file_name) { 'invalid_namespaces.xml' }

      it 'throws the appropriate error' do
        expect { ADAL::WSTrustResponse.parse(response) }
          .to raise_error(
            ADAL::WSTrustResponse::WSTrustError, /Unable to parse token/)
      end
    end

    context 'with an invalid abundance of security tokens' do
      let(:file_name) { 'too_many_security_tokens.xml' }

      it 'throws the appropriate error' do
        expect { ADAL::WSTrustResponse.parse(response) }
          .to raise_error(
            ADAL::WSTrustResponse::WSTrustError,
            /too many RequestedSecurityTokens/)
      end
    end

    context 'with no security tokens on the first token response node' do
      let(:file_name) { 'missing_security_tokens.xml' }
      let(:expected_token) { '<foo:Assertion xmlns:foo="bar"/>' }
      subject { ADAL::WSTrustResponse.parse(response) }

      it { expect { subject }.to_not raise_error }

      it 'should use the backup' do
        expect(subject.token.to_s).to eq(expected_token)
      end
    end
  end

  describe '#grant_type' do
    context 'with a SAML1 token type' do
      subject do
        response = ADAL::WSTrustResponse.new(
          'irrelevant', ADAL::WSTrustResponse::TokenType::V1)
        response.grant_type
      end
      it { is_expected.to eq(ADAL::TokenRequest::GrantType::SAML1) }
    end

    context 'with a SAML2 token type' do
      subject do
        response = ADAL::WSTrustResponse.new(
          'irrelevant', ADAL::WSTrustResponse::TokenType::V2)
        response.grant_type
      end
      it { is_expected.to eq(ADAL::TokenRequest::GrantType::SAML2) }
    end

    # This case should not happen unless the developer is being intentionally
    # hacky. The constructor ensures that the token type is valid.
    context 'with an unrecognized token type' do
      subject do
        response = ADAL::WSTrustResponse.new(
          'irrelevant', ADAL::WSTrustResponse::TokenType::V1)
        response.instance_variable_set(:@token_type, 'not a token type')
        response.grant_type
      end
      it { is_expected.to be_nil }
    end
  end
end
