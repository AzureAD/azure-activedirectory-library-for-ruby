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
