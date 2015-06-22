module ADAL
  # A cache implementation that holds no values and ignores all method calls.
  class NoopCache
    # Swallows any number of parameters and returns nil.
    def noop(*); end

    alias_method :add, :noop
    alias_method :add_many, :noop
    alias_method :remove, :noop
    alias_method :remove_many, :noop
    alias_method :find, :noop
  end
end
