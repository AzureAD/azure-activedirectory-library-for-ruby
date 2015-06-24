require 'logger'

module ADAL
  # Mix-in module for the ADAL logger.
  module Logging
    attr_reader :logger

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::WARN
  end
end
