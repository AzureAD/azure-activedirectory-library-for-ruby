# Extract all Ruby files in $DIR/lib/adal/ regardless of where the gem is built.
Dir[File.expand_path('../adal/*.rb', __FILE__)].each { |f| require_relative f }
