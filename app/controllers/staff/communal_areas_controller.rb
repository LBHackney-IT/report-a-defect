class Staff::CommunalAreasController < Staff::BaseController
  def show
    @communal_area = CommunalArea.find(id)
  end

  def new
    @scheme = Scheme.find(scheme_id)
    @communal_area = CommunalArea.new
  end

  def create
    @scheme = Scheme.find(scheme_id)
    @communal_area = CommunalArea.new(communal_area_params)
    @communal_area.scheme = @scheme

    if @communal_area.valid?
      @communal_area.save
      flash[:success] = I18n.t('generic.notice.create.success', resource: 'communal_area')
      redirect_to estate_scheme_path(@scheme.estate, @scheme)
    else
      render :new
    end
  end

  def edit
    @scheme = Scheme.find(scheme_id)
    @communal_area = CommunalArea.find(id)
  end

  def update
    @scheme = Scheme.find(scheme_id)
    @communal_area = CommunalArea.find(id)
    @communal_area.assign_attributes(communal_area_params)

    if @communal_area.valid?
      @communal_area.save
      flash[:success] = I18n.t('generic.notice.update.success', resource: 'communal_area')
      redirect_to estate_scheme_path(@scheme.estate, @scheme)
    else
      render :edit
    end
  end

  private

  def id
    params[:id]
  end

  def scheme_id
    params[:scheme_id]
  end

  def communal_area_params
    params.require(:communal_area).permit(
      :name,
      :location
    )
  end
end
