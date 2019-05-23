class Staff::PropertiesController < Staff::BaseController
  def new
    @scheme = Scheme.find(scheme_id)
    @property = Property.new
  end

  def create
    @scheme = Scheme.find(scheme_id)
    @property = Property.new(property_params)
    @property.scheme = @scheme

    if @property.valid?
      @property.save
      flash[:success] = I18n.t('generic.notice.success', resource: 'property')
      redirect_to estate_scheme_path(@scheme.estate, @scheme)
    else
      render :new
    end
  end

  private

  def scheme_id
    params[:scheme_id]
  end

  def property_params
    params.require(:property).permit(:core_name, :address, :postcode)
  end
end
