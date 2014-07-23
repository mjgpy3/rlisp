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

class RlispExecutor
  SIMPLE_SEND = ->(x){ x[1].send(x.first, *x[2..-1]) }
  SIMPLE_SEND_MAPPED = ->(m, x){ SIMPLE_SEND.([m] + x[1..-1]) }

  OPERATIONS = {
    mod: ->(x){ SIMPLE_SEND.([:%] + x[1..-1]) },
    print: ->(x){ puts(*x[1..-1]) },
    if: ->(x){ x[1] ? x[2] : x[3] },
    eq: ->(x){ SIMPLE_SEND_MAPPED.(:equal?, x) },
    eql: ->(x){ SIMPLE_SEND_MAPPED.(:eql?, x) },
    range: ->(x){ (x[1]..x[2]-1).to_a }
  }

  def initialize
    @available_methods = OPERATIONS
  end

  def execute(to_execute)
    return to_execute[1] if [:quote, :`].include?(to_execute.first)
    op = to_execute.first

    if op == :defn
      @available_methods[to_execute[1]] = ->(x){ to_execute[3] }
      return
    end

    all = to_execute.
      map { |i| i.is_a?(Array) ? execute(i) : i }.
      select { |x| x }
    return @available_methods[op].(all) if OPERATIONS.include?(op)
    all.size == 1 ? all.first : SIMPLE_SEND.(all)
  end
end
