class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
   before_action :authenticate_user!, except: [:show]
   before_action :require_redacteur!, except: [:show]
   before_action :prepopulate_from_params, only: %i[ new edit update ]

  layout 'dashboard', except: [:show]
  def index
    @posts = Post.all
  end
  def show
    @post.increment_views
    prepopulate_from_params
    @prev   = Post.where('slug < ?', @post.slug).order(slug: :desc).first
    @next   = Post.where('slug > ?', @post.slug).order(slug: :asc).first
    @similar = Post.where(category: @post.category)
                 .where.not(id: @post.id)
                 .order(created_at: :desc)
                 .limit(5)
  end

  def new
    @post = Post.new
  end

  def edit
   @post.new_tag_names = @post.tags.map(&:name).join(', ') # on remplit
  end

  def create
    @post = Post.new(post_params)
    @post.views = 0
    @post.user = current_user

    if @post.save
      redirect_to @post, notice: "Post was successfully created."
    else
      prepopulate_from_params
      puts @post.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_url, notice: "Post was successfully destroyed."
  end

  private

  def set_post
    @post = Post.find_by!(slug: params[:slug])
  end

  def post_params
    params.require(:post).permit(:title, :content, :cover_image, :category_id, :new_category_name, :new_tag_names, :slug, :status, :featured)
  end

  def prepopulate_from_params
    # si le formulaire a déjà été soumis on remet les valeurs tapées
    @post.new_category_name = params[:post][:new_category_name] if params[:post]
    @post.new_tag_names     = params[:post][:new_tag_names]     if params[:post]
  end
end