require 'rails_helper'

RSpec.describe NotifyViewHelper, type: :helper do
  describe '#notify_link' do
    it 'returns back a markdown link' do
      result = helper.notify_link('http://localhost:3000/hello', 'A bit of text')
      expect(result).to eql('[A bit of text](http://localhost:3000/hello)')
    end

    context 'when no text is given' do
      it 'sets the link text to the same as the link' do
        result = helper.notify_link('http://localhost:3000/hello')
        expect(result).to eq('[http://localhost:3000/hello](http://localhost:3000/hello)')
      end
    end
  end

  describe '#accept_defect_ownership_link' do
    it 'returns a capitalized string' do
      result = helper.accept_defect_ownership_link('foo')
      expect(result).to eql("[#{I18n.t('email.defect.forward.accept.link')}](http://test.host/defects/foo/accept)")
    end
  end
end
