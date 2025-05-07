class Staff::SchemesController < Staff::BaseController
  def new
    @estate = Estate.find(estate_id)
    @scheme = Scheme.new
  end

  def create
    @estate = Estate.find(estate_id)
    @scheme = Scheme.new(scheme_params)
    @scheme.set_start_date(start_date)
    @scheme.estate = @estate

    if @scheme.valid?
      @scheme.save
      flash[:success] = I18n.t('generic.notice.create.success', resource: 'scheme')
      redirect_to estate_url(@estate)
    else
      render :new
    end
  end

  def show
    @scheme = Scheme.find(scheme_id)
  end

  def edit
    @scheme = Scheme.find(scheme_id)
  end

  def update
    @scheme = Scheme.find(scheme_id)
    @scheme.assign_attributes(scheme_params)
    @scheme.set_start_date(start_date)

    if @scheme.valid?
      @scheme.save
      flash[:success] = I18n.t('generic.notice.update.success', resource: 'scheme')
      redirect_to estate_scheme_url(@scheme.estate, @scheme)
    else
      render :edit
    end
  end

  private

  def estate_id
    params[:estate_id]
  end

  def scheme_id
    params[:id]
  end

  def start_date
    params.fetch(:start_date, {}).permit(:day, :month, :year)
  end

  def scheme_params
    params.require(:scheme).permit(
      :name,
      :contractor_name,
      :contractor_email_address,
      :employer_agent_name,
      :employer_agent_email_address,
      :employer_agent_phone_number,
      :project_manager_name,
      :project_manager_email_address
    )
  end
end
