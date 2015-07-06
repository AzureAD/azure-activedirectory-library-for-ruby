require_relative '../spec_helper'

include FakeData

describe ADAL::ClientAssertion do
  describe '#initialize' do
    it 'should fail if any parameters are nil' do
      expect do
        ADAL::ClientAssertion.new(nil, ASSERTION)
      end.to raise_error(ArgumentError)
      expect do
        ADAL::ClientAssertion.new(CLIENT_ID, nil)
      end.to raise_error(ArgumentError)
    end
  end
end
