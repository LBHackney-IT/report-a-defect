class ReferenceNumber
  FORMAT = /^ *NB-(\d+)-(\d+) *$/i.freeze

  def self.parse(string)
    match = FORMAT.match(string)
    return nil unless match

    number = (match[1] + match[2]).to_i
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
