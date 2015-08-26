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

require 'uri'

describe ADAL::AuthenticationParameters do
  describe '::create_from_resource_url' do
    it 'should make an request to the resource server and parse the response' do
      expect(Net::HTTP).to receive(:post_form).once.and_return(
        'www-authenticate' => 'Bearer authorization_uri="sample.com"')
      params = ADAL::AuthenticationParameters.create_from_resource_url('a.io')
      expect(params.authority_uri).to eq(URI.parse('sample.com'))
    end

    it 'should fail if the url is not a valid url' do
      bad_url = 'this is not a valid url'
      expect do
        ADAL::AuthenticationParameters.create_from_resource_url(bad_url)
      end.to raise_error(URI::InvalidURIError)
    end

    it 'should fail if the response does not contain an authenticate header' do
      allow(Net::HTTP).to receive(:post_form).and_return(
        body: 'abc', 'content-type' => 'application/json')
      expect do
        ADAL::AuthenticationParameters.create_from_resource_url('myurl.com')
      end.to raise_error(ArgumentError)
    end

    it 'should fail if the resource server does not response' do
      allow(Net::HTTP).to receive(:post_form).and_raise(Timeout::Error)
      expect do
        ADAL::AuthenticationParameters.create_from_resource_url('myurl.com')
      end.to raise_error(Timeout::Error)
    end
  end

  describe '::create_from_authenticate_header' do
    it 'should successfully parse a valid authentication header' do
      params = ADAL::AuthenticationParameters.create_from_authenticate_header(
        'Bearer authorization_uri="foobar,lj,;l,", resource="a( res&*^ource"')
      expect(params.authority_uri).to eq(URI.parse('foobar,lj,;l,'))
      expect(params.resource).to eq('a( res&*^ource')
    end

    it 'should return nil if the input is nil' do
      expect(
        ADAL::AuthenticationParameters.create_from_authenticate_header(nil)
      ).to be_nil
    end

    it 'should return nil if the header does not contain an authority key' do
      expect(
        ADAL::AuthenticationParameters.create_from_authenticate_header(
          'Bearer: resource="http://graph.windows.net"')
      ).to be_nil
    end
  end

  describe '#create_context' do
    before(:each) do
      auth_uri = 'https://login.windows.net/mytenant.onmicrosoft.com'
      @auth_params = ADAL::AuthenticationParameters.new(auth_uri)
    end

    it 'should return an AuthenticationContext object' do
      expect(@auth_params.create_context).to be_a(ADAL::AuthenticationContext)
    end

    it 'should extract the host and tenant from the authorize uri' do
      # @authority does not have a getter, so we have to use Ruby voodoo.
      authority = @auth_params.create_context.instance_variable_get(:@authority)
      expect(authority.host).to eq('login.windows.net')
      expect(authority.tenant).to eq('mytenant.onmicrosoft.com')
    end
  end

  describe '#initialize' do
    it 'should fail if the authorize uri is not a valid uri' do
      bad_auth_uri = 'not a real parsable uri'
      expect do
        ADAL::AuthenticationParameters.new(bad_auth_uri)
      end.to raise_error(URI::InvalidURIError)
    end
  end
end
