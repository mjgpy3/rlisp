require './spec/spec_helper.rb'
require './lib/rlisp.rb'

describe '#Rlisp' do
  before(:each) { allow_any_instance_of(Object).to receive(:ok?).and_return(true) }

  context 'when executing an empty block' do
    subject { Rlisp {} }

    it { is_expected.to be_ok }
  end
end
