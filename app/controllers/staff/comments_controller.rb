class Staff::CommentsController < Staff::BaseController
  def new
    @defect = Defect.find(defect_id)
    @comment = Comment.new
  end

  def create
    @defect = Defect.find(defect_id)
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.defect = @defect

    if @comment.valid?
      @comment.save
      flash[:success] = I18n.t('generic.notice.create.success', resource: 'comment')
      redirect_to defect_path_for(defect: @defect)
    else
      render :new
    end
  end

  private

  def id
    params[:id]
  end

  def defect_id
    params[:defect_id]
  end

  def comment_params
    params.require(:comment).permit(:message)
  end

  def defect_path_for(defect:)
    if defect.communal?
      block_defect_path(defect.block, defect.id)
    else
      property_defect_path(defect.property, defect.id)
    end
  end
end
