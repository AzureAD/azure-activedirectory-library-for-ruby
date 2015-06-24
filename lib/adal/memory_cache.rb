module ADAL
  # A simple cache implementation that is not persisted across application runs.
  class MemoryCache
    # Reload the cache from serialized JSON.
    def self.from_json(_)
      fail NotImplementedError
    end

    def initialize
      @entries = {}
    end

    def add(_entries)
      fail NotImplementedError
    end

    def find(_query)
      fail NotImplementedError
    end

    # Serializes the contents of the cache to JSON.
    def to_json(*)
      fail NotImplementedError
    end

    def remove(_entries)
      fail NotImplementedError
    end
  end
end
