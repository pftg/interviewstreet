def operator_preced c
    case c
    when '!' then 4
    when /[*\/%]/ then 3
    when /[+-]/ then 2
    else 0
    end
end

def operator_left_assoc c
    case c
    when /[*\/%+-]/ then true
    else false
    end
end

OPERATORS = %w(+ - * / % !)

def opertaor? token
  OPERATORS.include? token
end

def push_op_to_out op

end

def shunting_yard str
  output = []
  operation_stack = []
  str.split.each do |token|
    case token
    when '(' then operation_stack << token
    when ')' then
      right_brace = operation_stack.rindex('(')
      output += operation_stack[right_brace + 1..-1].reverse
      operation_stack = operation_stack[0 ... right_brace]
    when /\d+/ then output << token
    when /[+-\\*\\%\/^]/ then
      ops = operation_stack.reverse.take_while do |op|
        op_preced = operator_preced(op)
        token_preced = operator_preced(token)

        opertaor?(op) && ( (operator_left_assoc(token) && (token_preced <= op_preced)) || (!operator_left_assoc(op) && (token_preced < op_preced)))
      end

      unless ops.empty?
        output += ops
        operation_stack = operation_stack[0 ... -1 * ops.length]
      end

      operation_stack << token
    end

  end
  output += operation_stack.reverse

  output
end


p shunting_yard "3 + 4 * 2 / ( 1 - 5 ) ^ 2 ^ 3"
