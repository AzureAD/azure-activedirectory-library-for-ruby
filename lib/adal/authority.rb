require_relative './logging'

require 'json'
require 'net/http'
require 'uri'
require 'uri_template'

module ADAL
  # An authentication and token server with the ability to self validate.
  class Authority
    include Logging

    AUTHORIZE_PATH = '/oauth2/authorize'
    DISCOVERY_TEMPLATE = URITemplate.new('https://{host}/common/discovery/' \
      'instance?authorization_endpoint={endpoint}&api-version=1.0')
    TENANT_DISCOVERY_ENDPOINT_KEY = 'tenant_discovery_endpoint'
    TOKEN_PATH = '/oauth2/token'
    WELL_KNOWN_AUTHORITY_HOSTS = [
      'login.windows.net',
      'login.microsoftonline.com',
      'login.chinacloudapi.cn',
      'login.cloudgovapi.us'
    ]
    WORLD_WIDE_AUTHORITY = 'login.microsoftonline.com'

    attr_reader :host
    attr_reader :tenant

    ##
    # Creates a new Authority.
    #
    # @param [String] host
    #   The host name of the authority server.
    # @param [String] tenant
    #   The name of the tenant for the Authority to access.
    # @option [Boolean] validate_authority (false)
    #   The setting that controls whether the Authority instance will check that
    #   it matches a set of know authorities or can dynamically retrieve an
    #   identifying response.
    def initialize(host, tenant, validate_authority = false)
      @host = host
      @tenant = tenant
      @validated = !validate_authority
    end

    public

    ##
    # URI that can be used to acquire authorization codes.
    #
    # @optional Hash params
    #   Query parameters that will added to the endpoint.
    # @return [URI]
    def authorize_endpoint(params = nil)
      if params.nil?
        URI::HTTPS.build(host: @host, path: '/' + @tenant + AUTHORIZE_PATH)
      else
        URI::HTTPS.build(host: @host,
                         path: '/' + @tenant + AUTHORIZE_PATH,
                         query: URI.encode_www_form(params))
      end
    end

    ##
    # URI that can be used to acquire tokens.
    #
    # @return [URI]
    def token_endpoint
      URI::HTTPS.build(host: @host, path: '/' + @tenant + TOKEN_PATH)
    end

    ##
    # Checks if the authority matches a set list of known authorities or if it
    # can be resolved by the discovery endpoint.
    #
    # @return [Boolean]
    #   True if the Authority was successfully validated.
    def validate
      @validated = validated_statically? unless validated?
      @validated = validated_dynamically? unless validated?
      @validated
    end

    # @return [Boolean]
    def validated?
      @validated
    end

    private

    ##
    # Creates an instance discovery endpoint url for authority that this object
    # represents.
    #
    # @return [URI]
    def discovery_uri(host = WORLD_WIDE_AUTHORITY)
      URI(DISCOVERY_TEMPLATE.expand(host: host, endpoint: authorize_endpoint))
    end

    ##
    # Performs instance discovery via a network call to well known authorities.
    #
    # @return [String]
    #   The tenant discovery endpoint, if found. Otherwise nil.
    def validated_dynamically?
      logger.verbose("Attempting instance discovery at: #{discovery_uri}.")
      response = JSON.parse(Net::HTTP.get(discovery_uri))
      unless response.key? TENANT_DISCOVERY_ENDPOINT_KEY
        logger.error('Received unexpected response from instance discovery ' \
                     "endpoint: #{response}. Unable to validate dynamically.")
        return
      end
      logger.verbose('Authority validated via dynamic instance discovery.')
      response[TENANT_DISCOVERY_ENDPOINT_KEY]
    end

    # @return [Boolean]
    def validated_statically?
      logger.verbose('Performing static instance discovery.')
      found_it = WELL_KNOWN_AUTHORITY_HOSTS.include? @host
      if found_it
        logger.verbose('Authority validated via static instance discovery.')
      end
      found_it
    end
  end
end
