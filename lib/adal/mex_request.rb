require_relative './mex_response'
require_relative './util'

require 'net/http'
require 'uri'

module ADAL
  # A request to a Metadata Exchange endpoint of an ADFS server. Used to obtain
  # the WSTrust endpoint for username and password authentication of federated
  # users.
  class MexRequest
    include Util

    ##
    # Constructs a MexRequest object for a specific URL endpoint.
    #
    # @param String|URI endpoint
    #   The Metadata Exchange endpoint.
    def initialize(endpoint)
      @endpoint = URI.parse(endpoint.to_s)
    end

    # @return MexResponse
    def execute
      request = Net::HTTP::Get.new(@endpoint.path)
      request.add_field('Content-Type', 'application/soap+xml')
      MexResponse.parse(http(@endpoint).request(request).body)
    end
  end
end
