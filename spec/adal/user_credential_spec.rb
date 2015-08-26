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

include FakeData

describe ADAL::UserCredential do
  let(:user_cred) { ADAL::UserCredential.new(USERNAME, PASSWORD) }
  let(:fed_url) { 'https://abc.def/' }

  before(:each) do
    expect(Net::HTTP).to receive(:get).once.and_return(
      "{\"account_type\": \"#{account_type}\", " \
      "\"federation_metadata_url\": \"#{fed_url}\"}")
  end

  context 'with a federated user' do
    let(:account_type) { 'Federated' }

    describe '#account_type' do
      subject { user_cred.account_type }

      it { is_expected.to eq ADAL::UserCredential::AccountType::FEDERATED }

      it 'should cache the response instead of making multiple HTTP requests' do
        # Note the .once in the before block.
        user_cred.account_type
        user_cred.account_type
      end
    end

    describe '#request_params' do
      subject { user_cred.request_params }
      let(:action) do
        'http://docs.oasis-open.org/ws-sx/ws-trust/200512/RSTRC/IssueFinal'
      end
      let(:grant_type) { 'grant_type' }
      let(:token) { 'token' }
      let(:wstrust_url) { 'https://ghi.jkl/' }

      before(:each) do
        expect_any_instance_of(ADAL::MexRequest).to receive(:execute)
          .and_return(double(wstrust_url: wstrust_url, action: action))
        expect_any_instance_of(ADAL::WSTrustRequest).to receive(:execute)
          .and_return(double(token: token, grant_type: grant_type))
      end

      it 'contains assertion, grant_type and scope' do
        expect(subject.keys).to contain_exactly(:assertion, :grant_type, :scope)
      end

      describe 'assertion' do
        subject { user_cred.request_params[:assertion] }

        it 'contains the base64 encoded token' do
          expect(Base64.decode64(subject)).to eq token
        end
      end

      describe 'scope' do
        subject { user_cred.request_params[:scope] }

        it { is_expected.to eq :openid }
      end
    end
  end

  context 'with a managed user' do
    let(:account_type) { 'Managed' }

    describe '#account_type' do
      subject { user_cred.account_type }
      it { is_expected.to eq ADAL::UserCredential::AccountType::MANAGED }
    end

    describe '#request_params' do
      it 'should contain username, password and grant type' do
        expect(user_cred.request_params.keys).to contain_exactly(
          :username, :password, :grant_type, :scope)
      end

      describe 'grant_type' do
        subject { user_cred.request_params[:grant_type] }

        it { is_expected.to eq 'password' }
      end
    end
  end

  context 'with an unknown account type user' do
    let(:account_type) { 'Unknown' }

    describe '#account_type' do
      subject { user_cred.account_type }
      it { is_expected.to eq ADAL::UserCredential::AccountType::UNKNOWN }
    end

    describe '#request_params' do
      it 'should throw an error' do
        expect { user_cred.request_params }.to raise_error(
          ADAL::UserCredential::UnsupportedAccountTypeError)
      end
    end
  end
end
