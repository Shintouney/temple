require 'rails_helper'

describe ProgressTracker do
  describe 'increment_processed_items' do
    it 'increments Redis hset value' do
      value = { 'processed_items' => 27 }
      Redis.any_instance.should_receive(:hgetall) { value }
      Redis.any_instance.should_receive(:hset).with(nil, :processed_items, 28)
      subject.increment_processed_items
    end
  end

  describe 'delete' do
    it 'deletes the Redis key' do
      Redis.any_instance.should_receive(:del)
      subject.delete
    end
  end

  describe 'progress_percentage' do
    it 'returns progress percentage' do
      progress = { 'processed_items' => 27, 'total_items' => 100 }
      Redis.any_instance.should_receive(:hgetall) { progress }
      expect(subject.progress_percentage).to eq(27)
    end
    it 'returns 100% completed percentage when no progress' do
      Redis.any_instance.should_receive(:hgetall)
      expect(subject.progress_percentage).to eq(100)
    end
  end

  describe 'in_progress?' do
    it 'returns true when key found' do
      Redis.any_instance.should_receive(:keys) { true }
      expect(subject.in_progress?).to eq(true)
    end
    it 'returns false when no key' do
      Redis.any_instance.should_receive(:keys)
      expect(subject.in_progress?).to eq(false)
    end
  end
end
