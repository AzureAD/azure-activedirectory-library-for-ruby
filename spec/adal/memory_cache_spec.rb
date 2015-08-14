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
