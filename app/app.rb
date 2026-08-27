require 'sinatra/base'
require 'rack/utils'
require_relative 'models/post'

class App < Sinatra::Base
  get '/' do
    @posts = Post.order(Sequel.desc(:posted_at)).all
    erb :index
  end

  get '/photos/:filename' do
    send_file File.join(ENV.fetch('PHOTO_STORAGE_DIR'), File.basename(params[:filename]))
  end

  helpers do
    # Builds the display markup for a post's shared link. Returns already-escaped
    # HTML (every interpolated value runs through escape_html), so the template
    # emits it raw. Only http(s) URLs become clickable anchors; anything else
    # renders as plain text. Story 1.8 will fold this into a shared sanitizer.
    def render_link(post)
      return '' if post.link_url.empty?

      label = post.link_name.empty? ? post.link_url : post.link_name
      safe_label = Rack::Utils.escape_html(label)
      suffix = post.link_source.empty? ? '' : " &mdash; #{Rack::Utils.escape_html(post.link_source)}"

      if post.link_url.match?(%r{\Ahttps?://}i)
        %(<a href="#{Rack::Utils.escape_html(post.link_url)}">#{safe_label}</a>#{suffix})
      else
        "#{Rack::Utils.escape_html(post.link_url)}#{suffix}"
      end
    end
  end
end
