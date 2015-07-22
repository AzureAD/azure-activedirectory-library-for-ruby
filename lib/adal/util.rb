module ADAL
  # Various helper methods that are useful across several classes and do not fit
  # into the class hierarchy.
  module Util
    def fail_if_arguments_nil(*args)
      fail ArgumentError, 'Arguments cannot be nil.' if args.any?(&:nil?)
    end

    # @param URI|String
    # @return Net::HTTP
    def http(uri)
      uri = URI.parse(uri.to_s)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http
    end

    ##
    # Converts every key and value of a hash to string.
    #
    # @param Hash
    # @return Hash
    def string_hash(hash)
      hash.map { |k, v| [k.to_s, v.to_s] }.to_h
    end
  end
end
