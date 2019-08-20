class Staff::CommunalDefectsController < Staff::BaseController
  def new
    @communal_area = CommunalArea.find(communal_area_id)
    @defect = Defect.new
  end

  def create
    @communal_area = CommunalArea.find(communal_area_id)

    options = { communal_area_id: communal_area_id, priority_id: priority_id }
    @defect = BuildDefect.new(defect_params: defect_params, options: options).call

    if @defect.valid?
      SaveCommunalDefect.new(
        defect: @defect,
        send_email_to_contractor: send_email_to_contractor,
        send_email_to_employer_agent: send_email_to_employer_agent
      ).call
      flash[:success] = I18n.t('generic.notice.create.success', resource: 'defect')
      redirect_to communal_area_path(@communal_area)
    else
      render :new
    end
  end

  def update
    defect = Defect.find(id)
    @defect = EditDefect.new(
      defect: defect,
      defect_params: defect_params,
      options: {
        priority_id: priority_id,
        target_completion_date: target_completion_date,
      }
    ).call

    return render :edit if @defect.invalid?

    UpdateDefect.new(defect: @defect).call

    if @defect.saved_change_to_status? && @defect.completed?
      redirect_to new_defect_completion_path(@defect)
    else
      flash[:success] = I18n.t('generic.notice.update.success', resource: 'defect')
      redirect_to communal_area_defect_path(@defect.communal_area, @defect)
    end
  end

  def show
    @defect = DefectPresenter.new(Defect.find(id))
  end

  def edit
    @defect = DefectPresenter.new(Defect.find(id))
  end

  private

  def id
    params[:id]
  end

  def communal_area_id
    params[:communal_area_id]
  end

  def priority_id
    params.require(:defect).permit(:priority)[:priority]
  end

  def target_completion_date
    params.require(:target_completion_date).permit(:day, :month, :year)
  end

  def defect_params
    params.require(:defect).permit(
      :title,
      :access_information,
      :description,
      :contact_name,
      :contact_email_address,
      :contact_phone_number,
      :trade,
      :status
    )
  end

  def send_email_to_contractor
    params.require(:defect).fetch('send_contractor_email', '1').downcase == '1'
  end

  def send_email_to_employer_agent
    params.require(:defect).fetch('send_employer_agent_email', '1').downcase == '1'
  end
end
