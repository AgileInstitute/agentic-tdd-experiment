require 'sinatra/base'
require_relative 'models/post'

class App < Sinatra::Base
  get '/' do
    @posts = Post.order(Sequel.desc(:posted_at)).all
    erb :index
  end

  get '/photos/:filename' do
    send_file File.join(ENV.fetch('PHOTO_STORAGE_DIR'), File.basename(params[:filename]))
  end
end
