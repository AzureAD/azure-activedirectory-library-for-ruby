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

  describe '#execute' do
    let(:uri) { 'https://microsoft.com/' }

    it 'parses the body as an ADAL::WSTrustResponse' do
      mex_response_body = 'mex body'
      expect_any_instance_of(Net::HTTP).to receive(:request).once
        .and_return(double(body: mex_response_body, code: '200'))
      expect(ADAL::WSTrustResponse).to receive(:parse).with(mex_response_body)
      subject.execute('some user', 'some password')
    end
  end
end
