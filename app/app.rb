require 'sinatra/base'
require_relative 'models/post'

class App < Sinatra::Base
  get '/' do
    @posts = Post.order(Sequel.desc(:posted_at)).all
    erb :index
  end
end
