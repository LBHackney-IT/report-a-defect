RSpec.describe ReferenceNumber do
  describe '.parse' do
    it 'matches a reference number string' do
      number = ReferenceNumber.parse('NB-123-456')
      expect(number.to_i).to eq(123_456)
    end

    it 'does not match any other string' do
      number = ReferenceNumber.parse('not a reference number')
      expect(number).to be_nil
    end
  end

  describe '#to_s' do
    it 'formats the number' do
      number = ReferenceNumber.new(123_456)
      expect(number.to_s).to eq('NB-123-456')
    end
  end
end
