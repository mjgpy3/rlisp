require './spec/spec_helper.rb'
require './lib/rlisp.rb'

describe '#Rlisp' do
  context 'when executing an empty block' do
    subject { Rlisp {} }

    it { is_expected.to be_nil }
  end

  {
    [:head, [42, 43, 44]] => 42,
    [:tail, [42, 43, 44]] => [43, 44],
    [:cons, 42, [43, 44]] => [42, 43, 44],
    [:map, :even?, [:range, 1, 4]] => [false, true, false],
    [:filter, :even?, [:range, 1, 5]] => [2, 4],
    [:if, true, 42, 43] => 42,
    [:if, false, 42, 43] => 43,
    [:range, 1, 10] => [1, 2, 3, 4, 5, 6, 7, 8, 9],
    [:eql, 'foobar', 'foobar'] => true,
    [:eql, 'foobar', 'spameggs'] => false,
    [:eq, 'foobar', 'foobar'] => false,
    [:eq, 42, 42] => true,
    [:quote, [:+, 21, 21]] => [:+, 21, 21],
    [:`, [:+, 21, 21]] => [:+, 21, 21],
    [:+, 21, 21] => 42,
    [:-, 63, 21] => 42,
    [:*, 7, 6] => 42,
    [:/, 84, 2] => 42,
    [:mod, 42, 45] => 42,
    [:+, [:*, 7, 3], 21] => 42,
    [:+, [:*, [:+, 3, 4], 3], 21] => 42,
    [] => [],
    [:or, true, true] => true,
    [:or, false, true] => true,
    [:or, true, false] => true,
    [:or, false, false] => false,
    [:and, true, true] => true,
    [:and, false, true] => false,
    [:and, true, false] => false,
    [:and, false, false] => false,
  }.each do |code, result|
    context "when executing #{code}" do
      subject { Rlisp { code } }

      it { is_expected.to eq(result) }
    end
  end

  context 'when executing a filter over a map over a range, using a defined function' do
    subject do
      Rlisp do
        [
          [:defn, :square, [:number], [:*, :number, :number]],
          [:filter, :even?, [:map, :square, [:range, 1, 5]]]
        ]
      end
    end

    it { is_expected.to eq([4, 16]) }
  end

  context 'when executing a print list' do
    subject { Rlisp { [:print, thing_to_print] } }
    let(:thing_to_print) { 'foobar' }

    context 'with a ruby string' do
      let(:thing_to_print) { 'Hello world' }

      specify { expect { subject }.to output(thing_to_print+"\n").to_stdout }
    end
  end

  context 'when executing a filter over a defined function' do
    subject do
      Rlisp do
        [
          [:defn, :even, [:a], [:eql, [:mod, :a, 2], 0]],
          [:filter, :even, [:`, [:range, 0, 11]]]
        ]
      end
    end

    it { is_expected.to eq([0, 2, 4, 6, 8, 10]) }
  end

  context 'when executing an `or`' do
    subject { Rlisp { [:or, a, b] } }

    {
      true => true,
      false => false,
      true => true,
      false => true
    }.each do |f, s|
      context "with #{f} and #{s}" do
        let(:a) { f }
        let(:b) { s }

        it { is_expected.to eq(a || b) }
      end
    end
  end

  context 'when executing an `and`' do
    subject { Rlisp { [:and, a, b] } }

    {
      true => true,
      false => false,
      true => true,
      false => true
    }.each do |f, s|
      context "with #{f} and #{s}" do
        let(:a) { f }
        let(:b) { s }

        it { is_expected.to eq(a && b) }
      end
    end
  end

  context 'when defining a function that performs a non-simple operation' do
    subject do
      Rlisp do
        [
          [:defn, :div_by, [:a, :b], [:eql, 0, [:mod, :a, :b]]],
          [:div_by, a, b]
        ]
      end
    end

    context 'and it is given some params' do
      let(:a) { 15 }
      let(:b) { 5 }

      it { is_expected.to be(true) }
    end
  end

  context 'when defining a function that adds two numbers' do
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
