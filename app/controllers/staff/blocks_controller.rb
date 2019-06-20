class Staff::BlocksController < Staff::BaseController
  def show
    @block = Block.find(id)
  end

  def new
    @scheme = Scheme.find(scheme_id)
    @block = Block.new
  end

  def create
    @scheme = Scheme.find(scheme_id)
    @block = Block.new(block_params)
    @block.scheme = @scheme

    if @block.valid?
      @block.save
      flash[:success] = I18n.t('generic.notice.create.success', resource: 'block')
      redirect_to estate_scheme_path(@scheme.estate, @scheme)
    else
      render :new
    end
  end

  private

  def id
    params[:id]
  end

  def scheme_id
    params[:scheme_id]
  end

  def block_params
    params.require(:block).permit(
      :name
    )
  end
end
