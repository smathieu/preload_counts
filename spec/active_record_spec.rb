require 'spec_helper'
require 'logger'

if ActiveRecord::VERSION::MAJOR < 3
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
else
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
  ActiveRecord::Base.logger = Logger.new(nil)
end

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :posts do |t|
      t.integer :parent_id
    end

    create_table :comments do |t|
      t.integer :post_id, :null => false
      t.datetime :deleted_at
    end

    create_table :moduled_other_comments do |t|
      t.integer :post_id, :null => false
    end
  end
end

setup_db

class Post < ActiveRecord::Base
  has_many :children, :class_name => 'Post', :foreign_key => 'parent_id'

  has_many :comments
  has_many :active_comments, :conditions => "deleted_at IS NULL",
    :class_name => 'Comment'

  has_many :moduled_other_comments, :class_name => 'Moduled::OtherComment'

  preload_counts :children
  preload_counts :comments => [:with_even_id]
  preload_counts :active_comments
  preload_counts :moduled_other_comments
end

class PostWithActiveComments < ActiveRecord::Base
  set_table_name :posts

  has_many :comments, :conditions => "deleted_at IS NULL",
    :foreign_key => 'post_id'
  preload_counts :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post

  if ActiveRecord::VERSION::MAJOR < 3
    named_scope :with_even_id, lambda { {:conditions => "comments.id % 2 == 0"} }
  else
    scope :with_even_id, where('id % 2 = 0')
  end
end

module Moduled
end
class Moduled::OtherComment < ActiveRecord::Base
  set_table_name 'moduled_other_comments'
  belongs_to :post
end

def create_data
  post = Post.create
  3.times { post.children.create }
  5.times { post.comments.create }
  5.times { post.comments.create :deleted_at => Time.now }

  2.times { post.moduled_other_comments.create }
end

create_data

describe Post do
  it "should have a preload_comment_counts scope" do
    Post.should respond_to(:preload_comment_counts)
  end

  it "should have a preload_moduled_comment_counts scope" do
    Post.should respond_to(:preload_moduled_other_comment_counts)
  end

  describe 'instance' do
    let(:post) { Post.first }

    it "should have a comment_count accessor" do
      post.should respond_to(:comments_count)
    end

    it "should be able to get count without preloading them" do
      post.comments_count.should equal(10)
    end

    it "should have an active_comments_count accessor" do
      post.should respond_to(:comments_count)
    end
  end

  describe 'instance with preloaded count' do
    let(:post) { Post.preload_comment_counts.first }

    it "should be able to get the association count" do
      post.comments_count.should equal(10)
    end

    it "should be able to get the association count with a scope" do
      post.with_even_id_comments_count.should equal(5)
    end
  end

  describe 'instance with preloaded moduled comment count' do
    let(:post) { Post.preload_moduled_other_comment_counts.first }

    it "should be able to get the moduled association count" do
      post.moduled_other_comments_count.should equal(2)
    end
  end

  describe 'instance with preloaded self-referential count' do
    let(:post) { Post.preload_child_counts.first }

    it "should be able to get the self-referential association count" do
      post.children_count.should equal(3)
    end
  end
end

describe PostWithActiveComments do
  describe 'instance with preloaded count' do
    let(:post) { PostWithActiveComments.preload_comment_counts.first }

    it "should be able to get the association count" do
      post.comments_count.should equal(5)
    end
  end
end
