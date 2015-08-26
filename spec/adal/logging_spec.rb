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

require_relative '../spec_helper'

describe ADAL::Logging do
  describe '::log_level=' do
    context 'with an invalid log level' do
      it 'should throw an error' do
        expect { ADAL::Logging.log_level = 'abc' }.to raise_error(ArgumentError)
      end
    end

    context 'with a valid log level' do
      it 'should not throw an error' do
        expect { ADAL::Logging.log_level = ADAL::Logger::VERBOSE }
          .to_not raise_error
        expect { ADAL::Logging.log_level = ADAL::Logger::INFO }
          .to_not raise_error
        expect { ADAL::Logging.log_level = ADAL::Logger::WARN }
          .to_not raise_error
        expect { ADAL::Logging.log_level = ADAL::Logger::ERROR }
          .to_not raise_error
        expect { ADAL::Logging.log_level = ADAL::Logger::FATAL }
          .to_not raise_error
      end
    end
  end
end
