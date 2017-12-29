class PostsController < ApplicationController
  before_action :authenticate_user!, only: %i[create destroy]

  def index
    @posts = Post.order('id DESC').limit(20)
    @posts = @posts.where('id < ?', params[:max_id]) if params[:max_id]

    respond_to do |format|
      format.html
      format.js
    end
  end

  def toggle_flag
    @post = Post.find(params[:id])

    @post.flag_at = if @post.flag_at
                      nil
                    else
                      Time.now
                    end
    @post.save!
    render json: { message: 'ok', flag_at: @post.flag_at, id: @post.id }
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    @post.save

      # redirect_to posts_path
    end

  def update
    sleep(2)
    @post = Post.find(params[:id])
    @post.update!(post_params)
    render json: { id: @post.id, message: 'ok' }
  end

  def rate
    @post = Post.find(params[:id])

    existing_score = @post.find_score(current_user)
    if existing_score
      existing_score.update(score: params[:score])
    else
      @post.scores.create(score: params[:score], user: current_user)
    end

    render json: { average_score: @post.average_score }
  end

  def destroy
    @post = current_user.posts.find(params[:id]) # 只能删除自己的贴文
    @post.destroy
    render json: { id: @post.id }
    # redirect_to posts_path
  end

  def like
    @post = Post.find(params[:id])
    unless @post.find_like(current_user)
      Like.create(user: current_user, post: @post)
    end
    # redirect_to posts_path
  end

  def unlike
    @post = Post.find(params[:id])
    like = @post.find_like(current_user)
    like.destroy
    # redirect_to posts_path
    render 'like'
  end

  protected

  def post_params
    params.require(:post).permit(:content, :category_id)
   end
end
