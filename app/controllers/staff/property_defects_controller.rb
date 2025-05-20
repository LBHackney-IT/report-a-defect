class Staff::PropertyDefectsController < Staff::BaseController
  def new
    @property = Property.find(property_id)
    @defect = Defect.new
    @defect.evidences.build
  end

  def create
    @property = Property.find(property_id)

    options = {
      property_id: property_id,
      priority_id: priority_id,
      created_at: created_at,
      user: current_user,
    }
    @defect = BuildDefect.new(defect_params: defect_params, options: options).call

    if @defect.valid?
      SavePropertyDefect.new(
        defect: @defect,
        send_email_to_contractor: send_email_to_contractor,
        send_email_to_employer_agent: send_email_to_employer_agent
      ).call
      flash[:success] = I18n.t('generic.notice.create.success', resource: 'defect')
      redirect_to property_url(@property)
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
      options: {
        priority_id: priority_id,
        target_completion_date: target_completion_date,
        actual_completion_date: actual_completion_date,
        created_at: created_at,
      }
    ).call

    return render :edit if @defect.invalid?

    UpdateDefect.new(defect: @defect).call

    if @defect.saved_change_to_status? && @defect.completed?
      redirect_to new_defect_completion_url(@defect)
    else
      flash[:success] = I18n.t('generic.notice.update.success', resource: 'defect')
      redirect_to property_defect_url(@defect.property, @defect)
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

  def target_completion_date
    params.require(:target_completion_date).permit(:day, :month, :year)
  end

  def actual_completion_date
    params.fetch(:actual_completion_date, {}).permit(:day, :month, :year)
  end

  def created_at
    params.fetch(:created_at, {}).permit(:day, :month, :year)
  end

  def defect_params
    params.require(:defect).permit(
      :title,
      :description,
      :contact_name,
      :contact_email_address,
      :contact_phone_number,
      :trade,
      :status,
      evidences_attributes: %i[supporting_file description]
    )
  end

  def send_email_to_contractor
    params.require(:defect).fetch('send_contractor_email', '1').downcase == '1'
  end

  def send_email_to_employer_agent
    params.require(:defect).fetch('send_employer_agent_email', '1').downcase == '1'
  end
end
