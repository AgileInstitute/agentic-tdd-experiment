require_relative 'spec_helper'
require_relative '../app/importer'

RSpec.describe Importer do
  before { Post.dataset.delete }

  describe '.import' do
    it 'creates a post from a text-only entry' do
      posts = [
        {
          'timestamp' => 1224121959,
          'data' => [{ 'post' => 'is visiting Austin TX for the very first time!' }],
          'title' => 'Rob Myers updated his status.'
        }
      ]

      Importer.import(posts)

      expect(Post.count).to eq(1)
      post = Post.first
      expect(post.text).to eq('is visiting Austin TX for the very first time!')
      expect(post.posted_at).to eq(Time.at(1224121959))
    end

    it 'skips an entry that has attachments' do
      posts = [
        {
          'timestamp' => 1229233152,
          'attachments' => [
            { 'data' => [{ 'media' => { 'uri' => 'posts/media/photo.jpg' } }] }
          ],
          'data' => [{ 'post' => 'Zen Fest 2008' }],
          'title' => 'Rob Myers added a new photo.'
        }
      ]

      Importer.import(posts)

      expect(Post.count).to eq(0)
    end

    it 'skips an entry with no post text at all' do
      posts = [
        { 'timestamp' => 1325336931, 'title' => 'Rob Myers updated his status.' }
      ]

      Importer.import(posts)

      expect(Post.count).to eq(0)
    end

    it 'repairs mis-encoded text on import' do
      posts = [
        {
          'timestamp' => 1224121959,
          'data' => [{ 'post' => 'pÃ¢tÃ© for lunch' }]
        }
      ]

      Importer.import(posts)

      expect(Post.first.text).to eq('pâté for lunch')
    end

    it 'imports multiple posts in one call, each with its own text and timestamp' do
      posts = [
        {
          'timestamp' => 1224121959,
          'data' => [{ 'post' => 'is visiting Austin TX for the very first time!' }]
        },
        {
          'timestamp' => 1224474310,
          'data' => [{ 'post' => 'is practicing his KPFA radio spot for Zen Fest 2008' }]
        }
      ]

      Importer.import(posts)

      expect(Post.count).to eq(2)
      expect(Post.order(:posted_at).map(&:text)).to eq([
        'is visiting Austin TX for the very first time!',
        'is practicing his KPFA radio spot for Zen Fest 2008'
      ])
    end
  end

  describe '.import_file' do
    it 'reads a JSON export file and imports its text-only posts' do
      Importer.import_file(File.expand_path('fixtures/sample_posts.json', __dir__))

      expect(Post.count).to eq(2)
      expect(Post.order(:posted_at).map(&:text)).to eq([
        'is visiting Austin TX for the very first time!',
        'is practicing his KPFA radio spot for Zen Fest 2008'
      ])
    end
  end
end
