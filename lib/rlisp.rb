def Rlisp
  to_execute = yield

  if to_execute.is_a?(Array)
    puts to_execute[1] if to_execute.first == :print
    to_execute[1] + to_execute[2] if to_execute.first == :+
  elsif to_execute.nil?
    nil
  else
    fail 'Must be given an Array'
  end
end
