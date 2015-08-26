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
