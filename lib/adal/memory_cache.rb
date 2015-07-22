require_relative './logging'

module ADAL
  # A simple cache implementation that is not persisted across application runs.
  class MemoryCache
    include Logging

    # Reload the cache from serialized JSON.
    def self.from_json(_)
      fail NotImplementedError
    end

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

    # Serializes the contents of the cache to JSON.
    def to_json(*)
      fail NotImplementedError
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
