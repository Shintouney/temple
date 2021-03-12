require 'rails_helper'

describe UsersDecorator do
  subject { UsersDecorator.new(users) }
  let(:users) { FactoryBot.create_list(:user, 3) }

  describe '#as_json_for_autocomplete' do
    it 'returns a filtered Array of Hashes' do
      subject.as_json_for_autocomplete.each do |user_hash|
        expect(user_hash[:id]).not_to be_nil
        expect(user_hash[:value]).not_to be_nil
      end
    end
  end
end
