class PostsController < ApplicationController
  skip_before_action :authenticate_token!, only: %i[index show]
  before_action :find_post, only: %i[show update destroy publish unpublish]

  def create
    post = current_user.posts.create!(post_params)
    render json: post, status: :created
  end

  def index
    if current_user
      render json: current_user.posts.descending
    else
      render json: Post.published.published_descending
    end
  end

  def show
    render json: @post
  end

  def update
    @post.update!(post_params)
    render json: @post
  end

  def destroy
    @post.destroy
  end

  def publish
    @post.publish!
    render json: @post
  end

  def unpublish
    @post.unpublish!
    render json: @post
  end

  private

  def post_params
    params.require(:post).permit(:title, :description, :body, :slug)
  end

  def find_post
    @post = if current_user
              current_user.posts.find params[:id]
            else
              Post.published.find params[:id]
            end
  end
end
