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
