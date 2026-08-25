require_relative 'spec_helper'
require_relative '../app/importer'

RSpec.describe Importer do
  before do
    Photo.dataset.delete
    Post.dataset.delete
  end

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

    describe 'with photo attachments' do
      let(:export_root) { File.expand_path('fixtures/export_root', __dir__) }

      it 'imports a post with one uncaptioned photo' do
        posts = [
          {
            'timestamp' => 1229233152,
            'attachments' => [
              { 'data' => [{ 'media' => { 'uri' => 'posts/media/photo1.jpg' } }] }
            ]
          }
        ]

        Importer.import(posts, export_root: export_root)

        expect(Post.count).to eq(1)
        post = Post.first
        expect(post.text).to eq('')
        expect(post.photos.size).to eq(1)
        expect(post.photos.first.caption).to eq('')
      end

      it "imports a post with one captioned photo, independent of the post's own text" do
        posts = [
          {
            'timestamp' => 1229233152,
            'data' => [{ 'post' => 'Post-level commentary' }],
            'attachments' => [
              {
                'data' => [
                  { 'media' => { 'uri' => 'posts/media/photo1.jpg', 'description' => 'Photo-level caption' } }
                ]
              }
            ]
          }
        ]

        Importer.import(posts, export_root: export_root)

        post = Post.first
        expect(post.text).to eq('Post-level commentary')
        expect(post.photos.first.caption).to eq('Photo-level caption')
      end

      it 'imports a post with multiple photos, preserving order' do
        posts = [
          {
            'timestamp' => 1229233152,
            'attachments' => [
              { 'data' => [{ 'media' => { 'uri' => 'posts/media/photo1.jpg', 'description' => 'First' } }] },
              { 'data' => [{ 'media' => { 'uri' => 'posts/media/photo2.jpg', 'description' => 'Second' } }] }
            ]
          }
        ]

        Importer.import(posts, export_root: export_root)

        post = Post.first
        expect(post.photos.map(&:caption)).to eq(%w[First Second])
      end

      it 'imports all photos from a single album attachment, preserving order and each photo\'s own caption' do
        posts = [
          {
            'timestamp' => 1229233152,
            'data' => [{ 'post' => 'Family photos from the reunion' }],
            'attachments' => [
              {
                'data' => [
                  { 'media' => { 'uri' => 'posts/media/photo1.jpg', 'description' => 'My first photo' } },
                  { 'media' => { 'uri' => 'posts/media/photo2.jpg', 'description' => 'My 2nd photo' } }
                ]
              }
            ]
          }
        ]

        Importer.import(posts, export_root: export_root)

        post = Post.first
        expect(post.text).to eq('Family photos from the reunion')
        expect(post.photos.map(&:caption)).to eq(['My first photo', 'My 2nd photo'])
      end

      it 'copies the photo file into app-controlled storage' do
        posts = [
          {
            'timestamp' => 1229233152,
            'attachments' => [
              { 'data' => [{ 'media' => { 'uri' => 'posts/media/photo1.jpg' } }] }
            ]
          }
        ]

        Importer.import(posts, export_root: export_root)

        photo = Post.first.photos.first
        expect(File.exist?(photo.path)).to be true
        expect(File.binread(photo.path)).to eq(File.binread(File.join(export_root, 'posts/media/photo1.jpg')))
      end
    end
  end

  describe '.import_file' do
    it 'reads a real export file and imports its posts, including photos' do
      export_root = File.expand_path('fixtures/export_root', __dir__)
      json_path = File.join(export_root, 'posts/your_posts_1.json')

      Importer.import_file(json_path, export_root)

      expect(Post.count).to eq(3)
      expect(Post.order(:posted_at).map(&:text)).to eq([
        'is visiting Austin TX for the very first time!',
        'is practicing his KPFA radio spot for Zen Fest 2008',
        'Zen Fest 2008: Roy has a habit of taking pics of me eating...or am I always eating?'
      ])

      photo_post = Post.order(:posted_at).last
      expect(photo_post.photos.size).to eq(1)
      expect(photo_post.photos.first.caption)
        .to eq('Zen Fest 2008: Roy has a habit of taking pics of me eating...or am I always eating?')
    end
  end
end
