class Staff::CommunalDefectsController < Staff::BaseController
  def new
    @block = Block.find(block_id)
    @defect = Defect.new
  end

  def create
    @block = Block.find(block_id)

    options = { block_id: block_id, priority_id: priority_id }
    @defect = BuildDefect.new(defect_params: defect_params, options: options).call

    if @defect.valid?
      SaveDefect.new(defect: @defect).call
      flash[:success] = I18n.t('generic.notice.create.success', resource: 'defect')
      redirect_to block_path(@block)
    else
      render :new
    end
  end

  def show
    @defect = Defect.find(id)
  end

  def edit
    @defect = Defect.find(id)
  end

  def update
    @defect = Defect.find(id)
    @defect.assign_attributes(defect_params)
    @defect.priority = Priority.find(priority_id) if priority_id.present?

    if @defect.valid?
      @defect.save
      flash[:success] = I18n.t('generic.notice.update.success', resource: 'defect')
      redirect_to block_defect_path(@defect.block, @defect)
    else
      render :edit
    end
  end

  private

  def id
    params[:id]
  end

  def block_id
    params[:block_id]
  end

  def priority_id
    params.require(:defect).permit(:priority)[:priority]
  end

  def defect_params
    params.require(:defect).permit(
      :title,
      :description,
      :contact_name,
      :contact_email_address,
      :contact_phone_number,
      :trade,
      :status
    )
  end
end
