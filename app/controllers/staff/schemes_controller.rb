class Staff::SchemesController < Staff::BaseController
  def new
    @estate = Estate.find(estate_id)
    @scheme = Scheme.new
  end

  def create
    @estate = Estate.find(estate_id)
    @scheme = Scheme.new(scheme_params)
    @scheme.estate = @estate

    if @scheme.valid?
      @scheme.save
      flash[:success] = I18n.t('generic.notice.success', resource: 'scheme')
      redirect_to estate_path(@estate)
    else
      render :new
    end
  end

  def show
    @scheme = Scheme.find(scheme_id)
  end

  private

  def estate_id
    params[:estate_id]
  end

  def scheme_id
    params[:id]
  end

  def scheme_params
    params.require(:scheme).permit(:name)
  end
end
