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

    describe 'with a link attachment' do
      it 'imports a bare link share whose only content is an external_context URL' do
        posts = [
          {
            'timestamp' => 1376912962,
            'data' => [{ 'update_timestamp' => 1376912962 }],
            'attachments' => [
              { 'data' => [{ 'external_context' => { 'url' => 'http://www.space.com/22175-nasa-needs-women-sally-ride.html' } }] }
            ]
          }
        ]

        Importer.import(posts)

        expect(Post.count).to eq(1)
        post = Post.first
        expect(post.text).to eq('')
        expect(post.link_url).to eq('http://www.space.com/22175-nasa-needs-women-sally-ride.html')
        expect(post.posted_at).to eq(Time.at(1376912962))
      end

      it 'imports a link share together with its commentary text' do
        posts = [
          {
            'timestamp' => 1358874441,
            'data' => [
              { 'post' => 'One of the most awesome foods in the world was also a world traveler.' },
              { 'update_timestamp' => 1358874441 }
            ],
            'attachments' => [
              { 'data' => [{ 'external_context' => { 'url' => 'http://www.npr.org/blogs/thesalt/2013/01/22/169980441/how-the-sweet-potato-crossed-the-pacific-before-columbus' } }] }
            ]
          }
        ]

        Importer.import(posts)

        post = Post.first
        expect(post.text).to eq('One of the most awesome foods in the world was also a world traveler.')
        expect(post.link_url).to eq('http://www.npr.org/blogs/thesalt/2013/01/22/169980441/how-the-sweet-potato-crossed-the-pacific-before-columbus')
      end

      it 'captures the link name and source when the export provides them' do
        posts = [
          {
            'timestamp' => 1384540841,
            'data' => [{ 'post' => 'Mindful puking.' }],
            'attachments' => [
              { 'data' => [{ 'external_context' => {
                'name' => "Four Ways to Meditate When You're Really, Really Sick",
                'source' => 'The Interdependence Project',
                'url' => 'http://www.theidproject.org/blog/lawrence-grecco/2013/11/15/four-ways-meditate-when-youre-really-really-sick'
              } }] }
            ]
          }
        ]

        Importer.import(posts)

        post = Post.first
        expect(post.link_name).to eq("Four Ways to Meditate When You're Really, Really Sick")
        expect(post.link_source).to eq('The Interdependence Project')
      end

      it 'leaves link name and source empty when the export gives only a URL' do
        posts = [
          {
            'timestamp' => 1376912962,
            'attachments' => [
              { 'data' => [{ 'external_context' => { 'url' => 'http://www.space.com/22175-nasa-needs-women-sally-ride.html' } }] }
            ]
          }
        ]

        Importer.import(posts)

        post = Post.first
        expect(post.link_name).to eq('')
        expect(post.link_source).to eq('')
      end

      it 'repairs mis-encoded characters in link commentary on import' do
        posts = [
          {
            'timestamp' => 1337748541,
            'data' => [{ 'post' => 'Great piece on pÃ¢tÃ© and other rich foods' }],
            'attachments' => [
              { 'data' => [{ 'external_context' => { 'url' => 'http://example.com/pate' } }] }
            ]
          }
        ]

        Importer.import(posts)

        expect(Post.first.text).to eq('Great piece on pâté and other rich foods')
      end

      it 'does not import a post whose only attachment is a URL-less external_context' do
        posts = [
          {
            'timestamp' => 1344369820,
            'data' => [],
            'attachments' => [
              { 'data' => [{ 'external_context' => { 'name' => 'Pete Behrens' } }] }
            ],
            'title' => 'Rob Myers followed a person on SlideShare.'
          }
        ]

        Importer.import(posts)

        expect(Post.count).to eq(0)
      end
    end
  end

  describe '.import_file' do
    let(:export_root) { File.expand_path('fixtures/export_root', __dir__) }
    let(:json_path) { File.join(export_root, 'posts/your_posts_1.json') }

    it 'reads a real export file and imports its posts, including photos' do
      Importer.import_file(json_path, export_root)

      expect(Post.count).to eq(6)
      expect(Post.order(:posted_at).map(&:text)).to eq([
        'is visiting Austin TX for the very first time!',
        'is practicing his KPFA radio spot for Zen Fest 2008',
        'Zen Fest 2008: Roy has a habit of taking pics of me eating...or am I always eating?',
        'One of the most awesome foods in the world was also a world traveler.',
        '',
        'Mindful puking.'
      ])

      photo_post = Post.first(text: 'Zen Fest 2008: Roy has a habit of taking pics of me eating...or am I always eating?')
      expect(photo_post.photos.size).to eq(1)
      expect(photo_post.photos.first.caption)
        .to eq('Zen Fest 2008: Roy has a habit of taking pics of me eating...or am I always eating?')
    end

    it 'imports the link-share posts from the export file, with their URL and metadata' do
      Importer.import_file(json_path, export_root)

      bare_link = Post.first(link_url: 'http://www.space.com/22175-nasa-needs-women-sally-ride.html')
      expect(bare_link.text).to eq('')
      expect(bare_link.link_name).to eq('')
      expect(bare_link.link_source).to eq('')

      commented_link = Post.first(link_url: 'http://www.npr.org/blogs/thesalt/2013/01/22/169980441/how-the-sweet-potato-crossed-the-pacific-before-columbus')
      expect(commented_link.text).to eq('One of the most awesome foods in the world was also a world traveler.')

      titled_link = Post.first(link_url: 'http://www.theidproject.org/blog/lawrence-grecco/2013/11/15/four-ways-meditate-when-youre-really-really-sick')
      expect(titled_link.text).to eq('Mindful puking.')
      expect(titled_link.link_name).to eq("Four Ways to Meditate When You're Really, Really Sick")
      expect(titled_link.link_source).to eq('The Interdependence Project')
    end
  end
end
