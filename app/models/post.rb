require_relative '../db'
require_relative 'photo'

class Post < Sequel::Model(:posts)
  one_to_many :photos, order: :position
end
