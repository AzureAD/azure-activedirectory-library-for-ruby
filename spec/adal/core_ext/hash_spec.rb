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
