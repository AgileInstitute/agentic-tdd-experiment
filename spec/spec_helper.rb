ENV['RACK_ENV'] = 'test'
ENV['DATABASE_URL'] = 'sqlite::memory:'

require 'rack/test'
require 'sequel'
require_relative '../app/db'

Sequel.extension :migration
Sequel::Migrator.run(DB, File.expand_path('../db/migrations', __dir__))

require_relative '../app/app'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  def app
    App
  end
end
