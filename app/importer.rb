require 'json'
require 'fileutils'
require_relative 'models/post'
require_relative 'models/photo'
require_relative 'text_repairer'

class Importer
  def self.import(posts, export_root: nil)
    posts.each do |post|
      text = extract_text(post)
      photos = extract_photos(post)
      link = extract_link(post)
      next if text.empty? && photos.empty? && link.nil?

      link ||= { url: '', name: '', source: '' }
      created = Post.create(
        text: text,
        posted_at: Time.at(post['timestamp']),
        created_at: Time.now,
        link_url: link[:url],
        link_name: link[:name],
        link_source: link[:source]
      )

      store_photos(created, photos, export_root)
    end
  end

  def self.import_file(json_path, export_root)
    import(JSON.parse(File.read(json_path)), export_root: export_root)
  end

  def self.extract_text(post)
    data = post['data']
    return '' unless data.is_a?(Array)

    entry = data.find { |item| item.key?('post') }
    entry ? TextRepairer.repair(entry['post']) : ''
  end

  # Every `attachments[].data[]` entry across a post, flattened, with the
  # array-shape guards applied once. Each entry is a hash keyed by its kind
  # (`media`, `external_context`, `place`, ...).
  def self.attachment_items(post)
    attachments = post['attachments']
    return [] unless attachments.is_a?(Array)

    attachments.flat_map do |attachment|
      data_items = attachment['data']
      data_items.is_a?(Array) ? data_items : []
    end
  end

  def self.extract_photos(post)
    attachment_items(post).filter_map do |item|
      media = item['media']
      next unless media

      { uri: media['uri'], caption: media['description'] || '' }
    end
  end

  def self.extract_link(post)
    attachment_items(post).each do |item|
      context = item['external_context']
      next unless context.is_a?(Hash) && context['url']

      return {
        url: context['url'],
        name: context['name'] || '',
        source: context['source'] || ''
      }
    end

    nil
  end

  def self.store_photos(post, photos, export_root)
    photos.each_with_index do |photo, index|
      source = File.join(export_root, photo[:uri])
      destination = File.join(ENV.fetch('PHOTO_STORAGE_DIR'), "#{post.id}-#{index}-#{File.basename(photo[:uri])}")
      FileUtils.mkdir_p(File.dirname(destination))
      FileUtils.cp(source, destination)

      Photo.create(post_id: post.id, path: destination, caption: photo[:caption], position: index)
    end
  end

  private_class_method :extract_text, :attachment_items, :extract_photos, :extract_link, :store_photos
end
