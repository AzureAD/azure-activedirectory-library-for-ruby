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

require_relative './logging'

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
  end
end
