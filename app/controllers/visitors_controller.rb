class VisitorsController < ApplicationController
  def index
    @schemes = Scheme.all
  end
end
