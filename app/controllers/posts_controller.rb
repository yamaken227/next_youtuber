class PostsController < ApplicationController
  impressionist actions: [:show]
  before_action :authenticate_user!, only: [:new, :create, :edit, :destroy]
  before_action :set_post, only: [:edit, :update]
  def index
    @posts = Post.order('RAND()').limit(6)
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    url = params[:post][:video_url]
    url = url.slice(-11, 11)
    @post.video_url = url
    if @post.save
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @post = Post.find(params[:id])
    impressionist(@post, nil, unique: [:session_hash])
    @message = Message.new
    @messages = @post.messages.order(id: 'DESC')
  end

  def destroy
    post = Post.find(params[:id])
    post_user = post.user_id
    if current_user.id == post.user_id
      post.destroy
      redirect_to user_path(post_user)
    else
      render 'users/show'
    end
  end

  def edit
    redirect_to root_path unless current_user.id == @post.user.id
  end

  def update
    if @post.update(post_params)
      redirect_to post_path
    else
      render :edit
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :highlights, :video_url)
          .merge(user_id: current_user.id)
  end

  def set_post
    @post = Post.find(params[:id])
  end
end
