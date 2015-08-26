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
