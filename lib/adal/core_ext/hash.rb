module ADAL
  # Adds helper methods to Hash. These are standard in Rails and are
  # commonplace in the Ruby community.
  module CoreExt
    # Same as #merge, but values in other_hash are prioritized over self.
    refine Hash do
      def reverse_merge(other_hash)
        other_hash.merge(self)
      end
    end
  end
end
