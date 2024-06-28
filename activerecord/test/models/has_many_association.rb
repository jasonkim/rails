# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  # gem "rails"
  # If you want to test against edge Rails replace the previous line with this:
  gem "rails", github: "rails/rails", branch: "main"

  gem "sqlite3", "~> 1.4"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.integer :commentable_id
  end

  create_table :comments, force: true do |t|
    t.integer :commentable_id
  end
end

class Post < ActiveRecord::Base
  has_many :comments, foreign_key: :commentable_id, primary_key: :commentable_id
end

class Comment < ActiveRecord::Base
  has_one :post, foreign_key: :commentable_id, primary_key: :commentable_id,
          inverse_of: :comments
end

class BugTest < Minitest::Test
  def test_association_stuff
    commentable_id = 1
    post = Post.create!(commentable_id: commentable_id)
    post.comments.create!(commentable_id: commentable_id)

    post = Comment.last.post
    assert post.comments.exists?
  end
end