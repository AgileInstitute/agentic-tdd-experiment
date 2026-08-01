ENV['RACK_ENV'] = 'test'

require 'rack/test'
require_relative '../app/app'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  def app
    App
  end
end
