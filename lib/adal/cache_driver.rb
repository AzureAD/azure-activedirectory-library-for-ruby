#-------------------------------------------------------------------------------
# Copyright (c) 2015 Micorosft Corporation
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#-------------------------------------------------------------------------------

using ADAL::CoreExt

module ADAL
  # Performs logical operations on the TokenCache in the context of one token
  # request.
  class CacheDriver
    include Logging
    include RequestParameters

    FIELDS = { user_info: USER_INFO,
               username: USERNAME,
               resource: RESOURCE }

    ##
    # Constructs a CacheDriver to interact with a token cache.
    #
    # @param String authority
    #   The URL of the authority endpoint.
    # @param ClientAssertion|ClientCredential|etc client
    #   The credentials representing the calling application. We need this
    #   instead of just the client id so that the tokens can be refreshed if
    #   necessary.
    # @param TokenCache token_cache
    #   The cache implementation to store tokens.
    # @optional Fixnum expiration_buffer_sec
    #   The number of seconds to use as a leeway when dealing with cache expiry.
    def initialize(
      authority, client, token_cache = NoopCache.new, expiration_buffer_sec = 0)
      @authority = authority
      @client = client
      @expiration_buffer_sec = expiration_buffer_sec
      @token_cache = token_cache
    end

    ##
    # Checks if a TokenResponse is successful and if so adds it to the token
    # cache for future retrieval.
    #
    # @param SuccessResponse token_response
    #   The successful token response to be cached. If it is not successful, it
    #   fails silently.
    def add(token_response)
      return unless token_response.instance_of? SuccessResponse
      logger.verbose('Adding successful TokenResponse to cache.')
      entry = CachedTokenResponse.new(@client, @authority, token_response)
      update_refresh_tokens(entry) if entry.mrrt?
      @token_cache.add(entry)
    end

    ##
    # Searches the cache for a token matching a specific query of fields.
    #
    # @param Hash query
    #   The fields to match against.
    # @return TokenResponse
    def find(query = {})
      query = query.map { |k, v| [FIELDS[k], v] if FIELDS[k] }.compact.to_h
      resource = query.delete(RESOURCE)
      matches = validate(
        find_all_cached_entries(
          query.reverse_merge(
            authority: @authority, client_id: @client.client_id))
      )
      resource_specific(matches, resource) || refresh_mrrt(matches, resource)
    end

    private

    ##
    # All cache entries that match a query. This matches keys in values against
    # a hash to method calls on an object.
    #
    # @param Hash query
    #   The fields to be matched and the values to match them to.
    # @return Array<CachedTokenResponse>
    def find_all_cached_entries(query)
      logger.verbose("Searching cache for tokens by keys: #{query.keys}.")
      @token_cache.find do |entry|
        query.map do |k, v|
          (entry.respond_to? k.to_sym) && (v == entry.send(k.to_sym))
        end.reduce(:&)
      end
    end

    ##
    # Attempts to obtain an access token for a resource with refresh tokens from
    # a list of MRRTs.
    #
    # @param Array[CachedTokenResponse]
    # @return SuccessResponse|nil
    def refresh_mrrt(responses, resource)
      logger.verbose("Attempting to obtain access token for #{resource} by " \
                     "refreshing 1 of #{responses.count(&:mrrt?)} matching " \
                     'MRRTs.')
      responses.each do |response|
        if response.mrrt?
          refresh_response = response.refresh(resource)
          return refresh_response if add(refresh_response)
        end
      end
      nil
    end

    ##
    # Searches a list of CachedTokenResponses for one that matches the resource.
    #
    # @param Array[CachedTokenResponse]
    # @return SuccessResponse|nil
    def resource_specific(responses, resource)
      logger.verbose("Looking through #{responses.size} matching cache " \
                     "entries for resource #{resource}.")
      responses.select { |response| response.resource == resource }
        .map(&:token_response).first
    end

    ##
    # Updates the refresh tokens of all tokens in the cache that match a given
    # MRRT.
    #
    # @param CachedTokenResponse mrrt
    #   A new MRRT containing a refresh token to update other matching cache
    #   entries with.
    def update_refresh_tokens(mrrt)
      fail ArgumentError, 'Token must contain an MRRT.' unless mrrt.mrrt?
      @token_cache.find.each do |entry|
        entry.refresh_token = mrrt.refresh_token if mrrt.can_refresh?(entry)
      end
    end

    ##
    # Checks if an array of current cache entries are still valid, attempts to
    # refresh those that have expired and discards those that cannot be.
    #
    # @param Array[CachedTokenResponse] entries
    #   The tokens to validate.
    # @return Array[CachedTokenResponse]
    def validate(entries)
      logger.verbose("Validating #{entries.size} possible cache matches.")
      valid_entries = entries.group_by(&:validate)
      @token_cache.remove(valid_entries[false] || [])
      valid_entries[true] || []
    end
  end
end
