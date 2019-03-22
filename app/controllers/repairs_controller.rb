class RepairsController < ApplicationController
  def new
    @repair = Repair.new
  end

  def create
    @repair = Repair.new(repair_params)

    if @repair.valid?
      flash[:notice] = I18n.t('repair.success.notice')
      redirect_to root_path
    else
      render :new
    end
  end

  private def repair_params
    params.require(:repair).permit(:description)
  end
end
