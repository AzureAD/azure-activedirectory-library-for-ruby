module ADAL
  # A simple cache implementation that is not persisted across application runs.
  class MemoryCache
    def initialize
      @entries = {}
    end

    def add(_entries)
      fail NotImplementedError
    end

    def find(_query)
      fail NotImplementedError
    end

    def remove(_entries)
      fail NotImplementedError
    end
  end
end
