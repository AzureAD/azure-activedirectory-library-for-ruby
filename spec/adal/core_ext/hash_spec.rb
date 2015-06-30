require 'spec_helper'

using ADAL::CoreExt

describe Hash do
  describe '#reverse_merge' do
    it 'should work on empty hashes' do
      expect({}.reverse_merge({})).to eq({})
    end

    it 'should work just like merge if the keys do not conflict' do
      hash1 = { a: 5, b: 10 }
      hash2 = { c: 8, d: 12 }
      expect(hash1.reverse_merge(hash2)).to eq(hash1.merge(hash2))
      expect(hash2.reverse_merge(hash1)).to eq(hash2.merge(hash1))
    end

    it "should prefer self's values to other_hash's values" do
      hash1 = { a: 5, c: 10 }
      hash2 = { a: 6, b: 15 }
      expect(hash1.reverse_merge(hash2)).to eq(a: 5, b: 15, c: 10)
      expect(hash2.reverse_merge(hash1)).to eq(a: 6, b: 15, c: 10)
    end
  end
end
