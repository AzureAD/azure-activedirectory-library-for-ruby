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

MEX_FIXTURES = File.expand_path('../../fixtures/mex', __FILE__)

describe ADAL::MexResponse do
  describe '::parse' do
    let(:response) { File.read(File.expand_path(file_name, MEX_FIXTURES)) }

    context 'with both 1.3 and 2005 endpoints' do
      let(:file_name) { 'microsoft.xml' }
      let(:wstrust_url_13) do
        'https://corp.sts.microsoft.com/adfs/services/trust/13/usernamemixed'
      end

      it 'should not raise an error' do
        expect { ADAL::MexResponse.parse(response) }.to_not raise_error
      end

      it 'should prefer the 1.3 endpoint' do
        expect(ADAL::MexResponse.parse(response).wstrust_url.to_s)
          .to eq(wstrust_url_13)
      end
    end

    context 'with only 1.3 wstrust endpoint' do
      let(:file_name) { 'only_13.xml' }
      let(:wstrust_13_url) do
        'https://fs.ajmichael.net/adfs/services/trust/13/usernamemixed'
      end

      it 'should parse the 1.3 wstrust endpoint' do
        expect(ADAL::MexResponse.parse(response).wstrust_url.to_s)
          .to eq(wstrust_13_url)
      end
    end

    context 'with only 2005 wstrust endpoint' do
      let(:file_name) { 'only_2005.xml' }
      let(:wstrust_2005_url) do
        'https://fs.ajmichael.net/adfs/services/trust/2005/usernamemixed'
      end

      it 'should parse the 2005 wstrust endpoint' do
        expect(ADAL::MexResponse.parse(response).wstrust_url.to_s)
          .to eq(wstrust_2005_url)
      end
    end

    context 'with a malformed response' do
      let(:file_name) { 'malformed.xml' }

      it 'should throw an error' do
        expect { ADAL::MexResponse.parse(response) }
          .to raise_error(
            ADAL::MexResponse::MexError, /No username token policy nodes/)
      end
    end

    context 'with insecure address' do
      let(:file_name) { 'insecureaddress.xml' }

      it 'should throw an error' do
        expect { ADAL::MexResponse.parse(response) }
          .to raise_error(ArgumentError)
      end
    end

    context 'with invalid namespaces' do
      let(:file_name) { 'invalid_namespaces.xml' }

      it 'should throw an error' do
        expect { ADAL::MexResponse.parse(response) }
          .to raise_error(
            ADAL::MexResponse::MexError, /No username token policy nodes/)
      end
    end

    context 'with no policy nodes' do
      let(:file_name) { 'no_username_token_policies.xml' }

      it 'should throw an error' do
        expect { ADAL::MexResponse.parse(response) }
          .to raise_error(
            ADAL::MexResponse::MexError, /No username token policy nodes/)
      end
    end

    context 'with no wstrust endpoints' do
      let(:file_name) { 'no_wstrust_endpoints.xml' }

      it 'should throw an error' do
        expect { ADAL::MexResponse.parse(response) }
          .to raise_error(
            ADAL::MexResponse::MexError, /No valid WS-Trust endpoints/)
      end
    end

    context 'with no matching bindings' do
      let(:file_name) { 'no_matching_bindings.xml' }

      it 'should throw an error' do
        expect { ADAL::MexResponse.parse(response) }
          .to raise_error(ADAL::MexResponse::MexError, /No matching bindings/)
      end
    end

    context 'with multiple valid endpoints' do
      let(:file_name) { 'multiple_endpoints.xml' }
      let(:first_wstrust_url) do
        'https://this.is.first.com/adfs/services/trust/13/usernamemixed'
      end
      subject { ADAL::MexResponse.parse(response) }

      it { expect { subject }.to_not raise_error }

      it 'should use the first endpoint' do
        expect(subject.wstrust_url.to_s).to eq(first_wstrust_url)
      end
    end
  end
end
