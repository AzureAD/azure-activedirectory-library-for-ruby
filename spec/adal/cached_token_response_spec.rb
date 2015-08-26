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

require_relative '../support/fake_data'
require_relative '../spec_helper'

include FakeData

describe ADAL::CachedTokenResponse do
  let(:authority) { ADAL::Authority.new(AUTHORITY, TENANT) }
  let(:client) { ADAL::ClientCredential.new(CLIENT_ID) }
  let(:expires_in) { 100 }
  let(:resource) { RESOURCE }
  let(:refresh_token) { REFRESH_TOKEN }
  let(:response) do
    ADAL::SuccessResponse.new(
      resource: resource, refresh_token: refresh_token, expires_in: expires_in)
  end

  describe '#initialize' do
    subject { -> { ADAL::CachedTokenResponse.new(client, authority, resp) } }

    context 'with a SuccessResponse' do
      let(:resp) { ADAL::SuccessResponse.new }

      it { is_expected.to_not raise_error }
    end

    context 'with an ErrorResponse' do
      let(:resp) { ADAL::ErrorResponse.new }

      it { is_expected.to raise_error ArgumentError }
    end
  end

  describe '#validate' do
    subject do
      ADAL::CachedTokenResponse.new(client, authority, response).validate
    end

    context 'with a non expired token' do
      let(:expires_in) { 100 }

      it { is_expected.to be_truthy }
    end

    context 'with an expired token' do
      let(:expires_in) { -100 }

      context 'with no refresh token' do
        let(:refresh_token) { nil }

        it { is_expected.to be_falsey }
      end

      context 'with a refresh token that fails to refresh' do
        let(:refresh_token) { REFRESH_TOKEN }
        before(:each) { stub_request(:post, /.*/).and_return(status: 500) }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#mrrt?' do
    subject { ADAL::CachedTokenResponse.new(client, authority, response) }

    context 'with a refresh_token' do
      let(:refresh_token) { REFRESH_TOKEN }

      context 'with a resource' do
        let(:resource) { RESOURCE }
        it { is_expected.to be_mrrt }
      end

      context 'without a resource' do
        let(:resource) { nil }
        it { is_expected.to_not be_mrrt }
      end
    end

    context 'wihout a refresh_token' do
      let(:refresh_token) { nil }

      context 'with a resource' do
        let(:resource) { RESOURCE }
        it { is_expected.to_not be_mrrt }
      end

      context 'without a resource' do
        let(:resource) { nil }
        it { is_expected.to_not be_mrrt }
      end
    end
  end

  describe '#can_refresh?' do
    let(:other) { ADAL::CachedTokenResponse.new(client, oauthority, response) }
    subject do
      ADAL::CachedTokenResponse.new(client, authority, response)
        .can_refresh?(other)
    end

    context 'when not an mrrt' do
      let(:oauthority) { authority }
      let(:refresh_token) { nil }

      it { is_expected.to be_falsey }
    end

    context 'when an mrrt' do
      context 'when fields match' do
        let(:oauthority) { authority }
        it { is_expected.to be_truthy }
      end

      context 'when fields do not match' do
        let(:oauthority) { 'some other authority' }
        it { is_expected.to be_falsey }
      end
    end
  end

  it 'provides proxy access to token response fields' do
    expect(
      ADAL::CachedTokenResponse.new(client, AUTHORITY, response).resource
    ).to eq RESOURCE
  end
end
