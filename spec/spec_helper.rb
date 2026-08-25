ENV['RACK_ENV'] = 'test'
ENV['DATABASE_URL'] = 'sqlite::memory:'
ENV['PHOTO_STORAGE_DIR'] = File.expand_path('../tmp/spec_photo_storage', __dir__)

require 'fileutils'
require 'rack/test'
require 'sequel'
require_relative '../app/db'

Sequel.extension :migration
Sequel::Migrator.run(DB, File.expand_path('../db/migrations', __dir__))

require_relative '../app/app'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:each) do
    FileUtils.rm_rf(ENV['PHOTO_STORAGE_DIR'])
    FileUtils.mkdir_p(ENV['PHOTO_STORAGE_DIR'])
  end

  def app
    App
  end
end
