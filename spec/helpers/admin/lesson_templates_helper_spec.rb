require 'rails_helper'

describe Admin::LessonTemplatesHelper do
  describe '#weekdays_options' do
    it "build an options array" do
      expect(helper.weekdays_options.length).to eql(7)
      expect(helper.weekdays_options.last.first).to eql(I18n.t('date.day_names')[0])
    end
  end
end
