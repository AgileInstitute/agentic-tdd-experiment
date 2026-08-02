require 'json'
require_relative 'models/post'

class Importer
  def self.import(posts)
    posts.each do |post|
      next unless text_only?(post)

      Post.create(
        text: post['data'].first['post'],
        posted_at: Time.at(post['timestamp']),
        created_at: Time.now
      )
    end
  end

  def self.import_file(path)
    import(JSON.parse(File.read(path)))
  end

  def self.text_only?(post)
    return false if post['attachments']

    data = post['data']
    data.is_a?(Array) && data.size == 1 && data.first.keys == ['post']
  end
end
