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

    context 'with a successful response' do
      let(:file_name) { 'microsoft.xml' }
      let(:wstrust_url) do
        'https://corp.sts.microsoft.com/adfs/services/trust/13/usernamemixed'
      end

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
        expect { ADAL::MexResponse.parse(response) }
          .to raise_error(ADAL::MexResponse::MexError)
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
          .to raise_error(ADAL::MexResponse::MexError)
      end
    end
  end
end
