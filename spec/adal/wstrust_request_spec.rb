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
