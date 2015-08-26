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

OAUTH_FIXTURES = File.expand_path('../../fixtures/oauth', __FILE__)

describe ADAL::TokenResponse do
  let(:response) { File.read(File.expand_path(file_name, OAUTH_FIXTURES)) }

  describe '::parse' do
    context 'with a successful response' do
      context 'with an id token' do
        let(:file_name) { 'success_with_id_token.json' }

        it 'should not raise any errors' do
          expect { ADAL::TokenResponse.parse(response) }.to_not raise_error
        end

        describe 'response' do
          subject { ADAL::TokenResponse.parse(response) }

          it { is_expected.to be_instance_of ADAL::SuccessResponse }

          describe '#error?' do
            # RSpec does some metaprogramming voodoo; this calls subject.error?.
            it { is_expected.to_not be_error }
          end
        end
      end

      context 'without an id token' do
        let(:file_name) { 'success.json' }

        it 'should not raise any errors' do
          expect { ADAL::TokenResponse.parse(response) }.to_not raise_error
        end

        describe 'response' do
          subject { ADAL::TokenResponse.parse(response) }

          it { is_expected.to be_instance_of ADAL::SuccessResponse }

          describe '#error?' do
            it { is_expected.to_not be_error }
          end
        end
      end
    end

    context 'with an error response' do
      let(:file_name) { 'error.json' }

      it 'should not raise any errors' do
        expect { ADAL::TokenResponse.parse(response) }.to_not raise_error
      end

      describe 'response' do
        subject { ADAL::TokenResponse.parse(response) }

        it { is_expected.to be_instance_of ADAL::ErrorResponse }

        describe '#error?' do
          it { is_expected.to be_error }
        end
      end
    end
  end

  context 'with a successful response' do
    let(:file_name) { 'success.json' }

    describe '::parse' do
    end
  end

  context 'with an error response' do
    let(:file_name) { 'error.json' }

    describe '::parse' do
    end
  end
end
