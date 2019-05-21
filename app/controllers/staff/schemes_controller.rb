class Staff::SchemesController < Staff::BaseController
  def new
    @scheme = Scheme.new
  end

  def create
    @scheme = Scheme.new(scheme_params)

    if @scheme.valid?
      @scheme.save
      flash[:notice] = I18n.t('scheme.success.notice')
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @scheme = Scheme.find(scheme_id)
  end

  private

  def scheme_id
    params[:id]
  end

  def scheme_params
    params.require(:scheme).permit(:name)
  end
end
