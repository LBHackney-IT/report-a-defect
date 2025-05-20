class ReferenceNumber
  FORMAT = /^ *NB([0-9-]+) *$/i

  def self.parse(string)
    match = FORMAT.match(string)
    return nil unless match

    number = match[1].scan(/\d/).join('').to_i
    new(number)
  end

  def initialize(number)
    @number = number
  end

  def to_i
    @number
  end

  def to_s
    format('NB-%06d', @number).gsub(/-(\d{3})/, '-\1-')
  end
end
