class Staff::PropertiesController < Staff::BaseController
  def show
    @property = Property.find(id)
  end

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
      flash[:success] = I18n.t('generic.notice.create.success', resource: 'property')
      redirect_to estate_scheme_path(@scheme.estate, @scheme)
    else
      render :new
    end
  end

  def edit
    @scheme = Scheme.find(scheme_id)
    @property = Property.find(id)
  end

  def update
    @scheme = Scheme.find(scheme_id)
    @property = Property.find(id)
    @property.assign_attributes(property_params)

    if @property.valid?
      @property.save
      flash[:success] = I18n.t('generic.notice.update.success', resource: 'property')
      redirect_to estate_scheme_path(@scheme.estate, @scheme)
    else
      render :edit
    end
  end

  def index
    @properties = PropertySearch.new(address: address).call
  end

  private

  def id
    params[:id]
  end

  def scheme_id
    params[:scheme_id]
  end

  def address
    params[:address]
  end

  def property_params
    params.require(:property).permit(:core_name, :address, :postcode)
  end
end
