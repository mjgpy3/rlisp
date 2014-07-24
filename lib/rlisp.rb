def Rlisp
  to_execute = yield

  if to_execute.is_a?(Array)
    RlispExecutor.new.execute(to_execute)
  elsif to_execute.nil?
    nil
  else
    fail 'Must be given an Array'
  end
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

class RlispExecutor
  SIMPLE_SEND = ->(x){ x[1].send(x.first, *x[2..-1]) }
  SIMPLE_SEND_MAPPED = ->(m, x){ SIMPLE_SEND.([m] + x[1..-1]) }
  QUOTES = [:quote, :`]

  OPERATIONS = {
    mod: ->(x){ SIMPLE_SEND.([:%] + x[1..-1]) },
    print: ->(x){ puts(*x[1..-1]) },
    if: ->(x){ x[1] ? x[2] : x[3] },
    eq: ->(x){ SIMPLE_SEND_MAPPED.(:equal?, x) },
    eql: ->(x){ SIMPLE_SEND_MAPPED.(:eql?, x) },
    range: ->(x){ (x[1]..x[2]-1).to_a },
    and: ->(x){ x[1] && x[2] },
    or: ->(x){ x[1] || x[2] },
    head: ->(x){ x[1].first }
  }

  def initialize
    @available_methods = OPERATIONS.clone
    @special_methods = {
      map: ->(x){ execute(x[2..-1]).map { |i| execute([x[1], i]) } },
      filter: ->(x){ execute(x[2..-1]).select { |i| execute([x[1], i]) } }
    }
  end

  def execute(to_execute, lookups = {})
    return to_execute unless to_execute.is_a?(Array)
    return to_execute[1] if quoted?(to_execute.first)

    if to_execute.first == :defn
      create_method(to_execute)
      return
    end

    execute_and_perform_lookups(to_execute, lookups)
  end

  private

  def execute_and_perform_lookups(array, lookups)
    after_evaluating_level(array, lookups) do |op, all|
      return OPERATIONS[op].(all) if OPERATIONS.include?(op)
      method = @available_methods[op]
      return execute(method.(all), method.lookups) if method
      return execute(all.first, lookups) if all.size == 1

      all.first.is_a?(Symbol) ? SIMPLE_SEND.(all) : all
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

  def create_method(array)
      method = CustomMethod.new(array)
      @available_methods[method.name] = method
  end

  def execute_elements(array, lookups)
    array.
      map { |i| i.is_a?(Array) ? execute(i, lookups) : i }.
      select { |x| !x.nil? }
  end
end
