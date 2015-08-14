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

require_relative './request_parameters'
require_relative './util'

module ADAL
  # A wrapper object for a client id and secret.
  class ClientCredential
    include RequestParameters
    include Util

    attr_reader :client_id
    attr_reader :client_secret

    def initialize(client_id, client_secret = nil)
      fail_if_arguments_nil(client_id)
      @client_id = client_id
      @client_secret = client_secret
    end

    # The relavent parameters from this credential for OAuth.
    def request_params
      { CLIENT_ID => @client_id, CLIENT_SECRET => @client_secret }
    end

    ##
    # Converts the fields in this object into a JSON string.
    #
    # @return String
    def to_json(_ = nil)
      JSON.unparse([client_id, client_secret])
    end

    ##
    # Reconstructs an object from JSOn that was serialized with
    # ClientCredential#to_json.
    #
    # @param Array json
    # @return ClientCredential
    def self.from_json(json)
      json = JSON.parse(json) if json.instance_of? String
      ClientCredential.new(*json)
    end
  end
end
