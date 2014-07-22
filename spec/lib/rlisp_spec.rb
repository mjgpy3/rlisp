require './spec/spec_helper.rb'
require './lib/rlisp.rb'

describe '#Rlisp' do
  context 'when executing an empty block' do
    subject { Rlisp {} }

    specify { expect { subject }.to_not raise_error }
  end

  context 'when executing a print list' do
    subject { Rlisp { [:print, thing_to_print] } }

    specify { expect { subject }.to_not raise_error }
  end
end
