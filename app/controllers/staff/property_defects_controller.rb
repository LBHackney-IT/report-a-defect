class Staff::PropertyDefectsController < Staff::BaseController
  def new
    @property = Property.find(property_id)
    @defect = Defect.new
  end

  def create
    @property = Property.find(property_id)

    options = { property_id: property_id, priority_id: priority_id }
    @defect = BuildDefect.new(defect_params: defect_params, options: options).call

    if @defect.valid?
      SavePropertyDefect.new(defect: @defect).call
      flash[:success] = I18n.t('generic.notice.create.success', resource: 'defect')
      redirect_to property_path(@property)
    else
      render :new
    end
  end

  def show
    @defect = DefectPresenter.new(Defect.find(id))
  end

  def edit
    @defect = DefectPresenter.new(Defect.find(id))
  end

  def update
    defect = Defect.find(id)
    @defect = EditDefect.new(
      defect: defect,
      defect_params: defect_params,
      options: { priority_id: priority_id }
    ).call

    if @defect.valid?
      @defect.save
      flash[:success] = I18n.t('generic.notice.update.success', resource: 'defect')
      redirect_to property_defect_path(@defect.property, @defect)
    else
      render :edit
    end
  end

  private

  def id
    params[:id]
  end

  def property_id
    params[:property_id]
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
