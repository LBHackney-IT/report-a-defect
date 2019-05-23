class Staff::EstatesController < Staff::BaseController
  def new
    @estate = Estate.new
  end

  def create
    @estate = Estate.new(estate_params)

    if @estate.valid?
      @estate.save
      flash[:success] = I18n.t('generic.notice.create.success', resource: 'estate')
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @estate = Estate.find(estate_id)
  end

  private

  def estate_id
    params[:id]
  end

  def estate_params
    params.require(:estate).permit(:name)
  end
end
