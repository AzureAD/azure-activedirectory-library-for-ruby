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

describe ADAL::MemoryCache do
  let(:authority) { ADAL::Authority.new('login.windows.net', 'contoso.org') }
  let(:client) { ADAL::ClientCredential.new('my client id', 'client secret') }
  let(:cache) { ADAL::MemoryCache.new }

  # Note that this test also relies on the correctness of TokenResponse#to_json
  # and CachedTokenResponse#to_json.
  describe '#to_json' do
    subject { cache.to_json }

    context 'when empty' do
      it { is_expected.to eq '[]' }
    end

    context 'with many tokens' do
      let(:expected_json) do
        "[{\"access_token\":\"abc\",\"token_type\":\"JWT\"},{\"access_token\"" \
        ":\"abc\",\"scope\":\"openid\"},{\"access_token\":\"abc\",\"resource" \
        "\":\"http://graph.windows.net\"}]"
      end
      let(:expected_json) do
        "[{\"authority\":[\"login.windows.net\",\"contoso.org\"],\"client_id" \
        "\":\"my client id\",\"token_response\":{\"access_token\":\"abc\",\"t" \
        "oken_type\":\"JWT\"}},{\"authority\":[\"login.windows.net\",\"contos" \
        "o.org\"],\"client_id\":\"my client id\",\"token_response\":{\"access" \
        "_token\":\"abc\",\"scope\":\"openid\"}},{\"authority\":[\"login.wind" \
        "ows.net\",\"contoso.org\"],\"client_id\":\"my client id\",\"token_re" \
        "sponse\":{\"access_token\":\"abc\",\"resource\":\"http://graph.windo" \
        "ws.net\"}}]"
      end
      before(:each) do
        cache_driver = ADAL::CacheDriver.new(authority, client, cache)
        cache_driver.add(
          ADAL::SuccessResponse.new(access_token: 'abc', token_type: 'JWT'))
        cache_driver.add(
          ADAL::SuccessResponse.new(access_token: 'abc', scope: 'openid'))
        cache_driver.add(
          ADAL::SuccessResponse.new(access_token: 'abc',
                                    resource: 'http://graph.windows.net'))
      end

      it 'properly serializes the cache' do
        expect(subject).to eq expected_json
      end
    end
  end

  describe '#from_json' do
    subject { ADAL::MemoryCache.from_json(json) }

    context 'when empty' do
      let(:json) { '[]' }
      it 'should contain no entries' do
        expect(subject.entries.length).to eq 0
      end
    end

    context 'with many tokens' do
      let(:json) { cache.to_json }
      before(:each) do
        cache_driver = ADAL::CacheDriver.new(authority, client, cache)
        cache_driver.add(
          ADAL::SuccessResponse.new(access_token: 'abc', token_type: 'JWT'))
        cache_driver.add(
          ADAL::SuccessResponse.new(access_token: 'abc', scope: 'openid'))
        cache_driver.add(
          ADAL::SuccessResponse.new(access_token: 'abc',
                                    resource: 'http://graph.windows.net'))
      end

      it 'has the correct number of entries' do
        expect(subject.entries.length).to eq 3
      end

      it 'reconstructs the entries' do
        subject.entries.each do |cache_entry|
          expect(cache_entry.authority.host).to eq authority.host
          expect(cache_entry.authority.tenant).to eq authority.tenant
        end
      end
    end
  end
end
