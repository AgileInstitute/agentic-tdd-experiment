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

    it 'renders a link post as an anchor pointing at its URL' do
      Post.create(text: '', link_url: 'http://www.space.com/22175-nasa-needs-women-sally-ride.html',
                  posted_at: Time.at(1376912962), created_at: Time.now)

      get '/'

      expect(last_response.body).to include('<a href="http://www.space.com/22175-nasa-needs-women-sally-ride.html">')
    end

    it 'uses the link name as the anchor text when present' do
      Post.create(text: '', link_url: 'http://www.npr.org/sweet-potato',
                  link_name: 'How the Sweet Potato Crossed the Pacific',
                  posted_at: Time.at(1358874441), created_at: Time.now)

      get '/'

      expect(last_response.body).to include('>How the Sweet Potato Crossed the Pacific</a>')
    end

    it 'falls back to the URL as the anchor text when there is no link name' do
      Post.create(text: '', link_url: 'http://www.space.com/sally-ride', link_name: '',
                  posted_at: Time.at(1376912962), created_at: Time.now)

      get '/'

      expect(last_response.body).to include('>http://www.space.com/sally-ride</a>')
    end

    it 'shows the link source alongside the link when present' do
      Post.create(text: '', link_url: 'http://www.theidproject.org/meditate',
                  link_name: 'Four Ways to Meditate When Sick',
                  link_source: 'The Interdependence Project',
                  posted_at: Time.at(1384540841), created_at: Time.now)

      get '/'

      expect(last_response.body).to include('The Interdependence Project')
    end

    it 'shows the commentary text together with the link when both are present' do
      Post.create(text: 'One of the most awesome foods in the world was also a world traveler.',
                  link_url: 'http://www.npr.org/sweet-potato',
                  posted_at: Time.at(1358874441), created_at: Time.now)

      get '/'

      body = last_response.body
      expect(body).to include('One of the most awesome foods in the world was also a world traveler.')
      expect(body).to include('<a href="http://www.npr.org/sweet-potato">')
    end

    it 'renders a non-http(s) link URL as plain text, not a clickable anchor' do
      Post.create(text: '', link_url: 'javascript:alert(1)',
                  posted_at: Time.at(1376912962), created_at: Time.now)

      get '/'

      body = last_response.body
      expect(body).not_to include('<a href="javascript:alert(1)"')
      expect(body).to include('javascript:alert(1)')
    end

    it 'escapes the link URL in the href attribute' do
      Post.create(text: '', link_url: 'http://example.com/a"><script>alert(1)</script>',
                  posted_at: Time.at(1376912962), created_at: Time.now)

      get '/'

      body = last_response.body
      expect(body).not_to include('"><script>alert(1)</script>')
      expect(body).to include('&quot;')
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
