class Staff::PrioritiesController < Staff::BaseController
  def new
    @scheme = Scheme.find(scheme_id)
    @priority = Priority.new
  end

  def create
    @scheme = Scheme.find(scheme_id)
    @priority = Priority.new(priority_params)
    @priority.scheme = @scheme

    if @priority.valid?
      @priority.save
      flash[:success] = I18n.t('generic.notice.success', resource: 'priority')
      redirect_to estate_scheme_path(@scheme.estate, @scheme)
    else
      render :new
    end
  end

  private

  def scheme_id
    params[:scheme_id]
  end

  def priority_params
    params.require(:priority).permit(:name, :days)
  end
end
