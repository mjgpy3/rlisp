require './spec/spec_helper.rb'
require './lib/rlisp.rb'

describe '#Rlisp' do
  context 'when executing an empty block' do
    subject { Rlisp {} }

    specify { expect { subject }.to_not raise_error }

    it { is_expected.to be_nil }
  end

  context 'when executing a print list' do
    subject { Rlisp { [:print, thing_to_print] } }
    let(:thing_to_print) { 'foobar' }

    specify { expect { subject }.to_not raise_error }

    context 'with a ruby string' do
      let(:thing_to_print) { "Hello world\n" }

      specify { expect { subject }.to output(thing_to_print).to_stdout }
    end
  end
end
