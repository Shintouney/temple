require 'rails_helper'

describe Slimpay::SynchronizeErrorReporting, type: :model do

  # TODO : Rewrite all tests with vcr instead of mocking
  describe '#execute'  do
    let(:synchronize) { Slimpay::SynchronizeErrorReporting.new }
    let(:file_name) { "REJ_#{Date.today.strftime('%Y%m%d')}.csv" }
    let(:file_remote_path) { "/out/#{file_name}"}
    let(:file_local_path) { File.join(Dir.tmpdir, 'slimpayerrorreporting', file_name) }

    before(:each) do
      @error_parser = Slimpay::ErrorParser.new('spec/fixtures/bad_slimpay_rtrans.csv')
    end

    context "with a successful connection" do
      it "should create a SuccessFactorsImport record with the downloaded file" do
        @tmpdir_mock = double('tmpdir')
        allow(Dir).to receive(:mktmpdir).with('slimpayerrorreporting').and_return(@tmpdir_mock)
        @sftp_mock = double('sftp')
        allow(Net::SFTP).to receive(:start).and_yield(@sftp_mock)
        @entry_mock = double('entry')
        allow(@sftp_mock).to receive_message_chain(:dir, :foreach).and_yield(@entry_mock)
        allow(@entry_mock).to receive_message_chain(:name, :include?).and_return(true)
        allow(@entry_mock).to receive(:name).and_return(file_name)
        allow(Rtransaction).to receive_message_chain(:where, :blank?).and_return true
        allow(Pathname).to receive_message_chain(:new, :join, :to_s).and_return(file_remote_path)
        allow(File).to receive(:join).and_return(file_local_path)

        allow(@sftp_mock).to receive(:download!).with(file_remote_path).and_return(@file)
        allow(File).to receive(:write).with(file_local_path, @file).and_return(@file)

        @tmpfile_path_mock = double 'tmpfile_path'
        allow(Slimpay::ErrorParser).to receive(:new).and_return(@error_parser)
        allow(@error_parser).to receive(:execute).and_return(true)

        allow(Rtransaction).to receive(:create!).and_return(true)

        expect { synchronize.execute }.not_to raise_error
      end
    end

    context "with a successful connection" do
      it "should create a SuccessFactorsImport record with the downloaded file" do
        @tmpdir_mock = double('tmpdir')
        allow(Dir).to receive(:mktmpdir).with('slimpayerrorreporting').and_return(@tmpdir_mock)
        @sftp_mock = double('sftp')
        allow(Net::SFTP).to receive(:start).and_yield(@sftp_mock)
        @entry_mock = double('entry')
        allow(@sftp_mock).to receive_message_chain(:dir, :foreach).and_yield(@entry_mock)
        allow(@entry_mock).to receive_message_chain(:name, :include?).and_return(true)
        allow(@entry_mock).to receive(:name).and_return(file_name)
        allow(Rtransaction).to receive_message_chain(:where, :blank?).and_return true
        allow(Pathname).to receive_message_chain(:new, :join, :to_s).and_return(file_remote_path)
        allow(File).to receive(:join).and_return(file_local_path)
        allow(@sftp_mock).to receive(:download!).with(file_remote_path).and_raise(Net::SSH::AuthenticationFailed)

        expect { synchronize.execute }.to raise_error(Net::SSH::AuthenticationFailed)
      end
    end
  end
end
