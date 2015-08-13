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
      it('has the correct unique id') { expect(subject.unique_id).to eq oid }
      it('has the correct displayable id') { expect(subject.displayable_id).to eq upn }
    end

    context 'with no upn' do
      context 'with an email' do
        let(:claims) do
          { email: email, sub: sub, oid: oid, unique_name: unique_name }
        end
        it('is displayable') { expect(subject).to be_displayable }
        it('is unique') { expect(subject).to be_unique }
        it('has the correct unique id') { expect(subject.unique_id).to eq oid }
        it('has the correct displayable id') { expect(subject.displayable_id).to eq email }
      end

      context 'with no email' do
        context 'with a subject' do
          let(:claims) { { sub: sub, oid: oid, unique_name: unique_name } }
          it('is not displayable') { expect(subject).to_not be_displayable }
          it('is unique') { expect(subject).to be_unique }
          it('has the correct unique id') { expect(subject.unique_id).to eq oid }
          it('has the correct displayable id') { expect(subject.displayable_id).to be_nil }
        end

        context 'with no oid' do
          context 'with a subject' do
            let(:claims) { { sub: sub, unique_name: unique_name } }
            it('is displayable') { expect(subject).to_not be_displayable }
            it('is unique') { expect(subject).to be_unique }
            it('has the correct unique id') { expect(subject.unique_id).to eq sub }
            it('has the correct displayable id') { expect(subject.displayable_id).to be_nil }
          end

          context 'with no oid' do
            let(:claims) { {} }
            it('is not displayable') { expect(subject).to_not be_displayable }
            it('is not unique') { expect(subject).to_not be_unique }
            it 'has the correct unique id' do
              expect(subject.unique_id).to be_nil
            end
            it 'has the correct displayable id' do
              expect(subject.unique_id).to be_nil
            end
          end
        end
      end
    end
  end
end
