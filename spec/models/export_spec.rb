require 'rails_helper'

describe Export, type: :model do
  describe 'remove_dependencies' do
    it 'calls remove_dependencies on destroy' do
      subject.should_receive(:remove_dependencies)
      subject.destroy
    end
    it 'calls for tracker and file deletion' do
      subject.should_receive(:delete_progress_tracker)
      subject.should_receive(:delete_file)
      subject.destroy
    end
  end

  describe 'delete_progress_tracker' do
    it 'destroys the progress tracker' do
      subject.progress_tracker.should_receive(:delete)
      subject.send(:delete_progress_tracker)
    end
  end

  describe 'delete_file' do
    it 'destroys the associated file' do
      File.should_receive(:exist?) { true }
      File.should_receive(:delete)
      subject.send(:delete_file)
    end
  end
end
