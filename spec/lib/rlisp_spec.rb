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

  context 'when defining a function that addds two numbers' do
    subject do
      Rlisp do
        [
          [:defn, :add, [:a, :b], [:+, :a, :b]],
          [:add, a, b]
        ]
      end
    end

    context 'and that function is passed 21 and 21' do
      let(:a) { 21 }
      let(:b) { 21 }

      it { is_expected.to eq(42) }
    end

  end

  context 'when defining a function that doubles a number' do
    subject do
      Rlisp do
        [
          [:defn, :double, [:num], [:*, :num, 2]],
          [:double, value]
        ]
      end
    end

    context 'and that function is passed 21' do
      let(:value) { 21 }

      it { is_expected.to eq(42) }
    end
  end

  context 'when defining a function that returns 5 and calling it' do
    subject do
      Rlisp do
        [
          [:defn, :foo_func, [], [5]],
          [:foo_func]
        ]
      end
    end

    it { is_expected.to eq(5) }
  end

  context 'when executing an if' do
    subject { Rlisp { [:if, condition, true_value, false_value] } }

    context 'when the true element is 42 and the false is 35' do
      let(:true_value) { 42 }
      let(:false_value) { 35 }

      context 'when the condition is true' do
        let(:condition) { true }

        it { is_expected.to eq(true_value) }
      end

      context 'when the condition is false' do
        let(:condition) { false }

        it { is_expected.to eq(false_value) }
      end
    end
  end

  context 'when executing a range' do
    subject { Rlisp { [:range, a, b] } }

    context 'when going from 1 to 10' do
      let(:a) { 1 }
      let(:b) { 10 }

      it { is_expected.to eq([1, 2, 3, 4, 5, 6, 7, 8, 9]) }
    end
  end

  context 'when checking for shallow equality' do
    subject { Rlisp { [:eql, a, b] } }

    context 'when the objects have the same value' do
      let(:a) { 'foobar' }
      let(:b) { 'foobar' }

      it { is_expected.to eq(true) }
    end

    context 'when the objects have different values, but the same type' do
      let(:a) { 'foobar' }
      let(:b) { 'spameggs' }

      it { is_expected.to eq(false) }
    end
  end

  context 'when checking for identical-object equality' do
    subject { Rlisp { [:eq, a, b] } }

    context 'when the compared are the same object' do
      let(:thing) { Object.new }
      let(:a) { thing }
      let(:b) { thing }

      it { is_expected.to eq(true) }
    end

    context 'when the compared are different objects' do
      let(:a) { Object.new }
      let(:b) { Object.new }

      it { is_expected.to eq(false) }
    end

    context 'when the compared things have the same value' do
      let(:a) { 'foobar' }
      let(:b) { 'foobar' }

      it { is_expected.to eq(false) }
    end
  end

  context 'when executing a quote' do
    subject { Rlisp { [quote, quoted_entity] } }

    context 'when using the backtick symbol' do
      let(:quote) { :` }

      context 'with an `Array`' do
        let(:quoted_entity) { [:+, 21, 21] }

        it { is_expected.to eq(quoted_entity) }
      end
    end

    context 'when using the quote symbol' do
      let(:quote) { :quote }

      context 'with an `Array`' do
        let(:quoted_entity) { [:+, 21, 21] }

        it { is_expected.to eq(quoted_entity) }
      end
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
      [:+, [:*, [:+, 3, 4], 3], 21] => 42,
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
