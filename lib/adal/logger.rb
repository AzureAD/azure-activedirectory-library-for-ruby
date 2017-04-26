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

require 'logger'

module ADAL
  # Extended version of Ruby's base logger class to support VERBOSE logging.
  # This is consistent with ADAL logging across platforms.
  #
  # The format of a log message is described in the Ruby docs at
  # http://ruby-doc.org/stdlib-2.2.2/libdoc/logger/rdoc/Logger.html as
  # SeverityID, [DateTime #pid] SeverityLabel -- ProgName: message.
  # SeverityID is the first letter of the severity. In the case of ADAL::ADLogger
  # that means one of {V, I, W, E, F}. The DateTime object uses the to_s method
  # of DateTime from stdlib which is ISO-8601. The ProgName will be the
  # correlation id if one is sent or absent otherwise.
  class ADLogger < Logger
    SEVS = %w(VERBOSE INFO WARN ERROR FATAL)
    VERBOSE = SEVS.index('VERBOSE')

    ##
    # Constructs a new Logger.
    #
    # @param String|IO logdev
    #   A filename (String) or IO object (STDOUT, STDERR).
    # @param String correlation_id
    #   The UUID of the request context.
    def initialize(logdev, correlation_id)
      super(logdev)
      @correlation_id = correlation_id
    end

    def format_severity(severity)
      SEVS[severity] || 'ANY'
    end

    ##
    # For some reason, the default logger implementations of #error, #fatal,
    # etc. pass message = nil and progname = <the message> to #add, which
    # interprets that as using the progname as the message. Instead, we will
    # use the message as the message and the progname as the correlation_id.
    #
    # This is purely an internal change, the calling mechanism is exactly the
    # same and it only affects ADAL::ADLogger, not Logger.

    # These methods are skipped by the SimpleCov, because it is not our
    # responsibility to test the standard library's logging framework.

    #:nocov:
    def error(message = nil, &block)
      add(ERROR, message, @correlation_id, &block)
    end

    def fatal(message = nil, &block)
      add(FATAL, message, @correlation_id, &block)
    end

    def info(message = nil, &block)
      add(INFO, message, @correlation_id, &block)
    end

    def verbose(message = nil, &block)
      add(VERBOSE, message, @correlation_id, &block)
    end

    def warn(message = nil, &block)
      add(WARN, message, @correlation_id, &block)
    end
    #:nocov:
  end
end
