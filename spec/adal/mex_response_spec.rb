#-------------------------------------------------------------------------------
# # Copyright (c) Microsoft Open Technologies, Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
# ANY IMPLIED WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A
# PARTICULAR PURPOSE, MERCHANTABILITY OR NON-INFRINGEMENT.
#
# See the Apache License, Version 2.0 for the specific language
# governing permissions and limitations under the License.
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
