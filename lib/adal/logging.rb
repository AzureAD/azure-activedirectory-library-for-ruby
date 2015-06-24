require 'logger'

module ADAL
  # Mix-in module for the ADAL logger.
  module Logging
    ADAL_LOGLEVEL_ERROR = Logger::ERROR
    ADAL_LOGLEVEL_WARN = Logger::WARN
    ADAL_LOGLEVEL_INFO = Logger::INFO
    ADAL_LOGLEVEL_VERBOSE = Logger::DEBUG

    attr_reader :logger

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::WARN

    ##
    # Sets the ADAL log level.
    #
    # Example usage:
    #   ADAL::log_level = ADAL::Logging::ADAL_LOGLEVEL_ERROR
    #
    def log_level=(level)
      @logger.level = level
    end
  end
end
