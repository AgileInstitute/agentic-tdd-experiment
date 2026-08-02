require_relative 'spec_helper'
require_relative '../app/models/post'

RSpec.describe App do
  before { Post.dataset.delete }

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
  end
end
