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

require_relative '../spec_helper'

describe ADAL::UserIdentifier do
  describe '#initialize' do
    context 'with a valid type' do
      subject { -> { ADAL::UserIdentifier.new('a@io', :DISPLAYABLE_ID) } }
      it { is_expected.to_not raise_error }
    end

    context 'with an invalid type' do
      subject { -> { ADAL::UserIdentifier.new('a@io', :NEW_ID) } }
      it { is_expected.to raise_error ArgumentError }
    end
  end

  describe 'request_parameters' do
    let(:id) { 'my id' }
    let(:type) { ADAL::UserIdentifier::UNIQUE_ID }
    let(:user_id) { ADAL::UserIdentifier.new(id, type) }
    subject { user_id.request_params }
    it { is_expected.to eq(user_info: user_id) }
  end

  describe '==' do
    let(:id) { 'my id' }
    subject { ADAL::UserIdentifier.new(id, type) }

    context 'with another UserIdentifier' do
      let(:type) { ADAL::UserIdentifier::Type::UNIQUE_ID }
      it 'uses object equality' do
        expect(subject == subject).to be_truthy
        expect(subject == ADAL::UserIdentifier.new(id, type)).to be_falsey
      end
    end

    context 'with a string username' do
      let(:type) { ADAL::UserIdentifier::Type::UNIQUE_ID }
      it 'matches strings to the id' do
        expect(subject == id).to be_truthy
        expect(subject == '5').to be_falsey
      end
    end

    context 'with a UserInformation' do
      context 'with type UNIQUE_ID' do
        let(:type) { ADAL::UserIdentifier::Type::UNIQUE_ID }

        it 'matches oid' do
          user_info = ADAL::UserInformation.new(oid: id)
          expect(subject == user_info).to be_truthy
        end

        it 'matches sub' do
          user_info = ADAL::UserInformation.new(sub: id)
          expect(subject == user_info).to be_truthy
        end

        it 'does not match upn' do
          user_info = ADAL::UserInformation.new(upn: id)
          expect(subject == user_info).to be_falsey
        end

        it 'does not match email' do
          user_info = ADAL::UserInformation.new(email: id)
          expect(subject == user_info).to be_falsey
        end
      end

      context 'with type DISPLAYABLE_ID' do
        let(:type) { ADAL::UserIdentifier::Type::DISPLAYABLE_ID }

        it 'does not match oid' do
          user_info = ADAL::UserInformation.new(oid: id)
          expect(subject == user_info).to be_falsey
        end

        it 'does not match sub' do
          user_info = ADAL::UserInformation.new(sub: id)
          expect(subject == user_info).to be_falsey
        end

        it 'matches upn' do
          user_info = ADAL::UserInformation.new(upn: id)
          expect(subject == user_info).to be_truthy
        end

        it 'matches email' do
          user_info = ADAL::UserInformation.new(email: id)
          expect(subject == user_info).to be_truthy
        end
      end
    end
  end
end
