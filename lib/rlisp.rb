def Rlisp
  to_execute = yield

  if to_execute.is_a?(Array)
    puts to_execute[1] if to_execute.first == :print
  end
end
