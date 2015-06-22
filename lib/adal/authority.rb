require 'uri'
require 'uri_template'

module ADAL
  # An authentication and token server with the ability to self validate.
  class Authority
    AUTHORIZE_PATH = '/oauth2/authorize'
    DISCOVERY_TEMPLATE = URITemplate.new('https://{host}/common/discovery/' \
      'instance?authorization_endpoint={endpoint}&api-version=1.0')
    TOKEN_PATH = '/oauth2/token'
    WELL_KNOWN_AUTHORITY_HOSTS = [
      'login.windows.net',
      'login.microsoftonline.com',
      'login.chinacloudapi.cn',
      'login.cloudgovapi.us'
    ]
    WORLD_WIDE_AUTHORITY = 'login.windows.net'

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
    # @return [URI]
    def authorize_endpoint
      URI::HTTPS.build(host: @host, path: '/' + @tenant + AUTHORIZE_PATH)
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

    # @return [URI]
    def discovery_endpoint(host = WORLD_WIDE_AUTHORITY)
      URI(DISCOVERY_TEMPLATE.expand(host: host, endpoint: authorize_endpoint))
    end

    # @return [String]
    #   The tenant discovery endpoint, if found. Otherwise nil.
    def validated_dynamically?
      fail NotImplementedError
    end

    # @return [Boolean]
    def validated_statically?
      WELL_KNOWN_AUTHORITY_HOSTS.include? @host
    end
  end
end
