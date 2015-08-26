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
require_relative '../support/fake_data'

include FakeData

describe ADAL::CacheDriver do
  let(:authority) { ADAL::Authority.new(AUTHORITY, TENANT) }
  let(:client_id) { CLIENT_ID }
  let(:client) { ADAL::ClientCredential.new(client_id) }
  let(:driver) { ADAL::CacheDriver.new(authority, client, token_cache) }
  let(:success_response) { ADAL::SuccessResponse.new }

  describe '#add' do
    let(:token_cache) { ADAL::MemoryCache.new }

    context 'with an empty memory cache' do
      before(:each) { driver.add(success_response) }

      it 'should leave the cache with exactly one entry' do
        expect(token_cache.entries.size).to eq 1
      end

      it 'should put the token response in the token cache' do
        expect(token_cache.entries.map(&:token_response))
          .to include success_response
      end
    end

    context 'when the cache already contains the entry' do
      before(:each) do
        driver.add(success_response)
        driver.add(success_response)
      end

      it 'should not put a duplicate in the cache' do
        expect(token_cache.entries.uniq).to match_array(token_cache.entries)
      end

      it 'should leave the cache with the same number of entries' do
        expect(token_cache.entries.size).to eq 1
      end
    end

    context 'when the cache contains non-matching entries' do
      let(:idtoken1) { JWT.encode({ upn: 'user1' }, '') }
      let(:idtoken2) { JWT.encode({ upn: 'user2' }, '') }
      let(:token1) { ADAL::SuccessResponse.new(id_token: idtoken1) }
      let(:token2) { ADAL::SuccessResponse.new(id_token: idtoken2) }
      before(:each) do
        driver.add(token1)
        driver.add(token2)
        driver.add(ADAL::SuccessResponse.new(refresh_token: REFRESH_TOKEN,
                                             resource: RESOURCE,
                                             id_token: idtoken1))
      end

      it 'should update the refresh tokens of the matching entries' do
        expect(token1.refresh_token).to eq(REFRESH_TOKEN)
      end

      it 'should not update the refresh tokens of the non-matching entries' do
        expect(token2.refresh_token).to be nil
      end
    end
  end

  describe '#find' do
    let(:token_cache) { ADAL::MemoryCache.new }
    let(:resource1) { 'resource1' }
    let(:resource2) { 'resource2' }
    let(:user1) { 'user1' }
    let(:user2) { 'user2' }
    let(:user3) { 'user3' }
    let(:expiry) { 100 }
    let(:response1) do
      ADAL::SuccessResponse.new(resource: resource1,
                                user_info: user1,
                                expires_in: expiry)
    end
    let(:response2) do
      ADAL::SuccessResponse.new(resource: resource1,
                                user_info: user2,
                                expires_in: expiry,
                                refresh_token: REFRESH_TOKEN)
    end
    before(:each) do
      driver.add(response1)
      driver.add(response2)
    end

    let(:query) { { user_info: user, resource: resource } }
    subject { driver.find(query) }

    context 'with a user that is not in the cache' do
      let(:resource) { resource1 }
      let(:user) { user3 }
      it { is_expected.to be nil }
    end

    context 'with a user that is in the cache' do
      let(:user) { user2 }

      context 'with a resource that is in the cache' do
        let(:resource) { resource1 }

        context 'which is expired' do
          let(:expiry) { -10 }
          let(:updated_access_token) { 'some access token' }
          let(:refresh_response) do
            double(body: "{\"access_token\": \"#{updated_access_token}\", \"r" \
                         "esource\": \"#{resource1}\"}")
          end
          before(:each) do
            allow_any_instance_of(Net::HTTP).to receive(:request)
              .and_return(refresh_response)
          end

          it { is_expected.to_not be_nil }
          it 'should refresh the access token' do
            expect(subject.access_token).to eq(updated_access_token)
          end
        end

        context 'which is not expired' do
          it { is_expected.to be response2 }
        end
      end

      context 'with a resource that is not in the cache' do
        let(:resource) { resource2 }

        context 'without an mrrt' do
          let(:user) { user1 }
          it { is_expected.to be nil }
        end

        context 'with an mrrt' do
          it { is_expected.to_not be nil }
          it 'should fetch a new access token from OAuth' do
            expect(subject.access_token).to eq(RETURNED_TOKEN)
          end
        end
      end
    end

    context 'with no cache' do
      let(:token_cache) { ADAL::NoopCache.new }
      let(:user) { user1 }
      let(:resource) { resource1 }

      it { is_expected.to be_nil }
      it { expect { subject }.to_not raise_error }
    end
  end

  context 'with a nonmatching client' do
    describe '#find' do
      let(:query) { { resource: RESOURCE, client_id: client.client_id } }
      subject { driver.find(query) }

      let(:token_cache) { ADAL::MemoryCache.new }
      before(:each) do
        driver.add(ADAL::SuccessResponse.new(client_id: 'different client id'))
      end

      it { is_expected.to be_nil }
    end
  end
end
