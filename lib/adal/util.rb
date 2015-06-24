module ADAL
  # Various helper methods that are useful across several classes and do not fit
  # into the class hierarchy.
  module Util
    def fail_if_arguments_nil(*args)
      fail ArgumentError, 'Arguments cannot be nil.' if args.any?(&:nil?)
    end
  end
end

# Can't be in the ADAL namespaces or it makes a different Hash class.
class Hash
  # Standard in Rails, but not in the Ruby core libraries.
  def reverse_merge(other_hash)
    other_hash.merge(self)
  end
end
