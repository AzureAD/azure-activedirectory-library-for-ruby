require 'logger'

module ADAL
  # Extended version of Ruby's base logger class to support VERBOSE logging.
  # This is consistent with ADAL logging across platforms.
  class Logger < Logger
    SEVS = %w(VERBOSE INFO WARN ERROR FATAL)
    VERBOSE = SEVS.index('VERBOSE')

    def format_severity(severity)
      SEVS[severity] || 'ANY'
    end

    def verbose(progname = nil, &block)
      add(VERBOSE, nil, progname, &block)
    end
  end
end
