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

  OPERATIONS = {
    :mod => ->(x){ SIMPLE_SEND.([:%] + x[1..-1]) },
    print: ->(x){ puts(*x[1..-1]) }
  }

  def execute(to_execute)
    all = to_execute.map { |i| i.is_a?(Array) ? execute(i) : i }
    op = all.first
    OPERATIONS.include?(op) ? OPERATIONS[op].(all) : SIMPLE_SEND.(all)
  end
end
