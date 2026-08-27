require_relative 'spec_helper'
require_relative '../app/models/post'

RSpec.describe Post do
  before do
    Photo.dataset.delete
    Post.dataset.delete
  end

  it 'starts with the link fields blank' do
    post = Post.create(text: 'plain text post', posted_at: Time.at(1224121959), created_at: Time.now)

    expect(post.link_url).to eq('')
    expect(post.link_name).to eq('')
    expect(post.link_source).to eq('')
  end
end
