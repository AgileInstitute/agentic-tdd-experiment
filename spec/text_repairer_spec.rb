require_relative 'spec_helper'
require_relative '../app/text_repairer'

RSpec.describe TextRepairer do
  describe '.repair' do
    it 'fixes a known mojibake signature' do
      expect(TextRepairer.repair('pÃ¢tÃ©')).to eq('pâté')
    end

    it 'leaves plain ASCII text unaffected' do
      expect(TextRepairer.repair('Had a great day today!')).to eq('Had a great day today!')
    end

    it 'leaves genuinely-correct text with a literal Ã/Â untouched' do
      expect(TextRepairer.repair('Ã Coruña')).to eq('Ã Coruña')
    end

    it 'fixes multiple different mojibake signatures in one string' do
      expect(TextRepairer.repair('pÃ¢tÃ© and itâ€™s great'))
        .to eq('pâté and it’s great')
    end
  end
end
