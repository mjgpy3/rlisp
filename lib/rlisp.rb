def Rlisp
  to_execute = yield

  if to_execute.is_a?(Array)
    RlispExecutor.new(to_execute).execute
  elsif to_execute.nil?
    nil
  else
    fail 'Must be given an Array'
  end
end

class RlispExecutor

  SIMPLE_SEND = ->(x){ x[1].send(x.first, *x[2..-1]) }

  OPERATIONS = {
    :+ => SIMPLE_SEND,
    :- => SIMPLE_SEND,
    :* => SIMPLE_SEND,
    :/ => SIMPLE_SEND,
    print: ->(x){ puts(*x[1..-1]) }
  }

  def initialize(execution_array)
    @execute_me = execution_array
  end

  def execute
    OPERATIONS[@execute_me.first].(@execute_me)
  end
end
