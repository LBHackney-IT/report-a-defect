class Staff::BlocksController < Staff::BaseController
  def show
    @block = Block.find(id)
  end

  private

  def id
    params[:id]
  end
end
