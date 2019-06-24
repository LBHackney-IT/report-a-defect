class SaveCommunalDefect < SaveDefect
  def call
    defect.communal = true
    super
  end
end
