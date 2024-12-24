class Public::PostsController < Public::ApplicationController

  before_action :check_own_post, only: [:show]  # 自分の未了投稿のみ閲覧可能

  def index
    @posts = Post.where(is_completion: true).includes(:task)
    case params[:sort]
    when "いいね数順"
      @posts = @posts.left_joins(:favorites).group(:id).order('COUNT(favorites.id) DESC')
    when "コメント数順"
      @posts = @posts.left_joins(:comments).group(:id).order('COUNT(comments.id) DESC')
    else
      @posts = @posts.order(created_at: :desc) # 新しい順
    end
  end
  

  def show
    @post = Post.find(params[:id])
    if @post.is_completion == false && @post.user != current_user
      redirect_to posts_path, alert: "他のユーザーの未了投稿は閲覧できません。"
    end
    @comment = Comment.new
    @comments = @post.comments
  end

  def new
    @post = Post.new
    @task = Task.find_by(id: params[:task_id])
  end

  def create
    @post = current_user.posts.build(post_params)
    @post.end = @post.start
    if @post.save
      redirect_to user_path(current_user), notice: "スケジュールを作成しました。"
    else
      flash.now[:alert] = "スケジュール作成に失敗しました。タスクを選んで下さい。"
      @tasks = Task.all
      render :new
    end
  end

  def edit
    @post = Post.find(params[:id])
    unless @post.user_id == current_user.id
      redirect_to user_path(current_user), alert: '他の人の投稿編集を行う事は出来ません。'
    end
  end

  def update
    @post = Post.find(params[:id])
    if @post.user_id == current_user.id && post_params[:is_completion] == "true"
      if @post.update(post_params)
        redirect_to user_path(current_user), notice: 'タスクが完了しました。'
      else
        flash.now[:alert] = "かかった時間を入力して下さい。"
        render :edit, status: :unprocessable_entity
      end
    else
      redirect_to edit_post_path(@post)
    end
  end

  def destroy
    @post = Post.find(params[:id])
  # 自分の投稿かどうか確認
    if @post.user_id == current_user.id
      @post.destroy
      redirect_to user_path(current_user), notice: '投稿を削除しました'
    else
      redirect_to posts_path, alert: '投稿の削除権限がありません'
    end
  end
  
  private

  def post_params
    params.require(:post).permit(:task_id, :time_taken, :start, :end, :note, :is_completion)
  end

  def check_own_post
    @post = Post.find(params[:id])
    return if @post.user == current_user || @post.is_completion?

    redirect_to posts_path, alert: "この投稿を閲覧する権限がありません。"
  end

end
