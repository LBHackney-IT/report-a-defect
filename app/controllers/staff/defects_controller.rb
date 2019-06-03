class Staff::DefectsController < Staff::BaseController
  def new
    @property = Property.find(property_id)
    @defect = Defect.new
  end

  def create
    @property = Property.find(property_id)
    @defect = Defect.new(defect_params)
    @defect.property = @property
    @defect.priority = Priority.find(priority_id) if priority_id.present?

    if @defect.valid?
      @defect.save
      flash[:success] = I18n.t('generic.notice.create.success', resource: 'defect')
      redirect_to property_path(@property)
    else
      render :new
    end
  end

  def show
    @defect = Defect.find(id)
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
      :description,
      :contact_name,
      :contact_email_address,
      :contact_phone_number,
      :trade,
    )
  end
end
