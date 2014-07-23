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
      let(:thing_to_print) { 'Hello world' }

      specify { expect { subject }.to output(thing_to_print+"\n").to_stdout }
    end
  end

  context 'when executing a math operation' do
    subject { Rlisp { math_operation } }

    {
      [:+, 21, 21] => 42,
      [:-, 63, 21] => 42,
      [:*, 7, 6] => 42,
      [:/, 84, 2] => 42,
      [:mod, 42, 45] => 42,
      [:+, [:*, 7, 3], 21] => 42,
    }.each do |op, result|
      context "and that operation being #{op.inspect}" do
        let(:math_operation) { op }

        it { is_expected.to eq(result) }
      end
    end
  end

  [
    'foobar',
    Object.new,
    {},
    42
  ].each do |thing|
    context "when executing a non-`Array` that is `#{thing.inspect}`" do
      subject { Rlisp { thing } }

      specify { expect { subject }.to raise_error }
    end
  end
end
