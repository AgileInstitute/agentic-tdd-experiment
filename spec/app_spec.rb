require_relative 'spec_helper'
require_relative '../app/models/post'
require_relative '../app/models/photo'

RSpec.describe App do
  before do
    Photo.dataset.delete
    Post.dataset.delete
  end

  describe 'GET /' do
    it 'shows an imported post on the timeline' do
      Post.create(text: 'Had a great day today!', posted_at: Time.at(1224121959), created_at: Time.now)

      get '/'

      expect(last_response).to be_ok
      expect(last_response.body).to include('Had a great day today!')
    end

    it "shows the post's date" do
      Post.create(text: 'Had a great day today!', posted_at: Time.at(1224121959), created_at: Time.now)

      get '/'

      expect(last_response.body).to include('2008-10-16')
    end

    it 'shows posts newest-first' do
      Post.create(text: 'older post', posted_at: Time.at(1224121959), created_at: Time.now)
      Post.create(text: 'newer post', posted_at: Time.at(1224474310), created_at: Time.now)

      get '/'

      body = last_response.body
      expect(body.index('newer post')).to be < body.index('older post')
    end

    it "shows a post's photo" do
      post = Post.create(text: '', posted_at: Time.at(1224121959), created_at: Time.now)
      stored_path = File.join(ENV.fetch('PHOTO_STORAGE_DIR'), 'photo.jpg')
      File.write(stored_path, 'fake-jpeg-bytes')
      Photo.create(post_id: post.id, path: stored_path, caption: 'A sunny day', position: 0)

      get '/'

      expect(last_response.body).to include('<img src="/photos/photo.jpg"')
      expect(last_response.body).to include('A sunny day')
    end
  end

  describe 'GET /photos/:filename' do
    it 'serves the stored photo file' do
      stored_path = File.join(ENV.fetch('PHOTO_STORAGE_DIR'), 'photo.jpg')
      File.write(stored_path, 'fake-jpeg-bytes')

      get '/photos/photo.jpg'

      expect(last_response).to be_ok
      expect(last_response.body).to eq('fake-jpeg-bytes')
    end
  end
end
