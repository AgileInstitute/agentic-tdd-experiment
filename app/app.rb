require 'sinatra/base'

class App < Sinatra::Base
  get '/' do
    'OK'
  end
end
