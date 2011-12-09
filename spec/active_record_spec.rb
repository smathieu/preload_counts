require 'spec_helper'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :posts do |t|
    end

    create_table :comments do |t|
      t.integer :post_id, :null => false 
      t.datetime :deleted_at
    end
  end
end

setup_db 

class Post < ActiveRecord::Base
  has_many :comments
  has_many :active_comments, :conditions => "deleted_at IS NULL", :class_name => 'Comment'
  preload_counts :comments => [:with_even_id]
  preload_counts :active_comments
end

class PostWithActiveComments < ActiveRecord::Base
  set_table_name :posts

  has_many :comments, :conditions => "deleted_at IS NULL"
  preload_counts :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post

  named_scope :with_even_id, lambda { {:conditions => "comments.id % 2 == 0"} }
end

def create_data
  post = Post.create 
  5.times { post.comments.create }
  5.times { post.comments.create :deleted_at => Time.now }
end

create_data

describe Post do
  it "should have a preload_comment_counts scope" do
    Post.should respond_to(:preload_comment_counts) 
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

    it "should be able to get the association count with a named scope" do
      post.with_even_id_comments_count.should equal(5)
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
