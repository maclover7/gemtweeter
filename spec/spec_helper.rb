ENV['RACK_ENV'] = 'test'

require 'rack/test'
include Rack::Test::Methods

RSpec.configure do |config|
end
