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
