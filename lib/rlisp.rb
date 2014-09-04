def Rlisp
  to_execute = yield

  if to_execute.is_a?(Array)
    executor = RlispExecutor.new
    defn_lisp_core_functions(executor)
    executor.execute(to_execute)
  elsif to_execute.nil?
    nil
  else
    fail 'Must be given an Array'
  end
end

def defn_lisp_core_functions(executor)
  executor.add_method(:mod, ->(x){ simple_send_mapped(:%, x) })
    .add_method(:print, ->(x){ puts(*x[1..-1]) })
    .add_method(:if, ->(x){ x[1] ? x[2] : x[3] })
    .add_method(:eq, ->(x){ simple_send_mapped(:equal?, x) })
    .add_method(:eql, ->(x){ simple_send_mapped(:eql?, x) })
    .add_method(:range, ->(x){ (x[1]..x[2]-1).to_a })
    .add_method(:and, ->(x){ x[1] && x[2] })
    .add_method(:or, ->(x){ x[1] || x[2] })
    .add_method(:head, ->(x){ x[1].first })
    .add_method(:tail, ->(x){ simple_send_mapped(:drop, x[0..1]+[1]) })
    .add_method(:cons, ->(x){ simple_send_mapped(:unshift, [x[0], x[2], x[1]]) })
end

class CustomMethod
  def initialize(array)
    @array = array
    @params = {}
    @lookups = {}
    array[2].each_with_index { |p, i| @params[i] = p }
  end

  def call(x)
    x[1..-1].each_with_index { |v, i| @lookups[@params[i]] = v }
    @array[3]
  end

  def lookups
    @lookups
  end

  def name
    @array[1]
  end
end

def simple_send(x)
  x[1].send(x.first, *x[2..-1])
end

def simple_send_mapped(m, x)
  simple_send([m] + x[1..-1])
end

class RlispExecutor
  QUOTES = [:quote, :`]

  def initialize
    @available_methods = {}
    @special_methods = {
      map: ->(x){ execute(x[2..-1]).map { |i| execute([x[1], i]) } },
      filter: ->(x){ execute(x[2..-1]).select { |i| execute([x[1], i]) } }
    }
  end

  def execute(to_execute, lookups = {})
    return to_execute unless to_execute.is_a?(Array)
    return to_execute[1] if quoted?(to_execute.first)

    if to_execute.first == :defn
      create_method_from_array(to_execute)
      return
    end

    execute_and_perform_lookups(to_execute, lookups)
  end

  def add_method(name, method)
    @available_methods[name] = method
    return self
  end

  private

  def execute_and_perform_lookups(array, lookups)
    after_evaluating_level(array, lookups) do |op, all|
      method = @available_methods[op]
      return execute(method.(all)) if method.is_a?(Proc)
      return execute(method.(all), method.lookups) if method.is_a?(CustomMethod)
      return execute(all.first, lookups) if all.size == 1

      all.first.is_a?(Symbol) ? simple_send(all) : all
    end
  end

  def after_evaluating_level(array, lookups)
    op = array.first
    array = @special_methods[op].(array) if @special_methods[op]

    all = execute_elements(array, lookups).
      map { |x| lookups.include?(x) ? lookups[x] : x}

    yield(op, all)
  end

  def quoted?(thing)
    QUOTES.include?(thing)
  end

  def create_method_from_array(array)
    method = CustomMethod.new(array)
    add_method(method.name, method)
  end

  def execute_elements(array, lookups)
    array.
      map { |i| i.is_a?(Array) ? execute(i, lookups) : i }.
      select { |x| !x.nil? }
  end
end
