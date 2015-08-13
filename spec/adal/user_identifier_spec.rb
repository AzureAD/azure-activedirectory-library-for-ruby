require_relative '../spec_helper'

describe ADAL::UserIdentifier do
  describe '#initialize' do
    let(:upn) { 'adam' }
    let(:sub) { 'some subject' }
    let(:oid) { 'my oid' }
    let(:unique_name) { 'live.com#adam@contoso.org' }
    let(:email) { 'adam@contoso.org' }
    subject { ADAL::UserIdentifier.new(claims) }

    context 'with a upn' do
      let(:claims) do
        { upn: upn, email: email, sub: sub, oid: oid, unique_name: unique_name }
      end
      it('is displayable') { expect(subject).to be_displayable }
      it('has the correct user id') { expect(subject.user_id).to eq upn }
    end

    context 'with no upn' do
      context 'with an email' do
        let(:claims) do
          { email: email, sub: sub, oid: oid, unique_name: unique_name }
        end
        it('is displayable') { expect(subject).to be_displayable }
        it('has the correct user id') { expect(subject.user_id).to eq email }
      end

      context 'with no email' do
        context 'with a subject' do
          let(:claims) { { sub: sub, oid: oid, unique_name: unique_name } }
          it('is displayable') { expect(subject).to_not be_displayable }
          it('has the correct user id') { expect(subject.user_id).to eq sub }
        end

        context 'with no subject' do
          context 'with an oid' do
            let(:claims) { { oid: oid, unique_name: unique_name } }
            it('is displayable') { expect(subject).to_not be_displayable }
            it('has the correct user id') { expect(subject.user_id).to eq oid }
          end

          context 'with no oid' do
            context 'with a unique_name' do
              let(:claims) { { unique_name: unique_name } }
              it('is displayable') { expect(subject).to be_displayable }
              it 'has the correct user id' do
                expect(subject.user_id).to eq unique_name
              end
            end
          end
        end
      end
    end
  end
end
