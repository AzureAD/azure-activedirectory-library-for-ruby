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

module ADAL
  # A simple cache implementation that is not persisted across application runs.
  class MemoryCache
    include Logging

    def initialize
      @entries = []
    end

    attr_accessor :entries

    ##
    # Adds an array of objects to the cache.
    #
    # @param Array
    #   The entries to add.
    # @return Array
    #   The entries after the addition.
    def add(entries)
      entries = Array(entries)  # If entries is an array, this is a no-op.
      old_size = @entries.size
      @entries |= entries
      logger.verbose("Added #{entries.size - old_size} new entries to cache.")
    end

    ##
    # By default, matches all entries.
    #
    # @param Block
    #   A matcher on the token list.
    # @return Array
    #   The matching tokens.
    def find(&query)
      query ||= proc { true }
      @entries.select(&query)
    end

    ##
    # Removes an array of objects from the cache.
    #
    # @param Array
    #   The entries to remove.
    # @return Array
    #   The remaining entries.
    def remove(entries)
      @entries -= Array(entries)
    end

    ##
    # Converts the cache entries into one JSON string.
    #
    # @param JSON::Ext::Generator::State
    # @return String
    def to_json(_ = nil)
      JSON.unparse(entries)
    end

    ##
    # Reconstructs the cache from JSON that was previously serialized.
    #
    # @param JSON json
    # @return MemoryCache
    def self.from_json(json)
      cache = MemoryCache.new
      cache.entries = JSON.parse(json).map do |e|
        CachedTokenResponse.from_json(e)
      end
      cache
    end
  end
end
