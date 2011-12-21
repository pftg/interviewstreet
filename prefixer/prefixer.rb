IDENTIFIER_REGEXP = /[+-]?\d+|\w+/
OPERATOR_REGEXP = /[+-\\*\\%\/^]/

def operator_preced c
    case c
    when '^' then 5
    when '!' then 4
    when /[*\/%]/ then 3
    when /[+-]/ then 2
    else 0
    end
end

def operator_left_assoc c
    case c
    when /[*\/%+-^]/ then true
    else false
    end
end

def operator_args_count token
  token == '!' ? 1 : 2
end

def ident? token
  token.match /\d+|\w+/
end

OPERATORS = %w(+ - * / % ! ^)
SPECIAL_RUBY_OPERATORS_MAPS = { "^" => "**" }

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
    when IDENTIFIER_REGEXP then output << token
    when OPERATOR_REGEXP then
      # Find less preceds operators then current operator
      ops = operation_stack.reverse.take_while do |op|
        op_preced = operator_preced(op)
        token_preced = operator_preced(token)

        is_operator = op =~ OPERATOR_REGEXP
        is_operator && ( (operator_left_assoc(token) && (token_preced <= op_preced)) || (!operator_left_assoc(op) && (token_preced < op_preced)))
      end

      # Push less preced operators to the output
      unless ops.empty?
        output += ops
        operation_stack = operation_stack[0 ... -1 * ops.length]
      end

      # add operator to the operator stack
      operation_stack << token
    end

  end
  output += operation_stack.reverse

  output
end

def eval_rpn_expression expression, &visitor
  identifiers = []
  expression.each do |token|
    case token
    when IDENTIFIER_REGEXP then
      identifiers << token
    when OPERATOR_REGEXP then
      #take operators identifiers
      arg_count = operator_args_count(token)
      operands = identifiers[-1 * arg_count .. -1]
      identifiers = identifiers[0...-1 * arg_count]
      result = yield(token, operands)
      identifiers << result
    end
  end

  raise "Bad RPN Expression: there are > 1 operands without operators" if identifiers.size > 1

  identifiers.first
end

p infix_expression = "3 + 4 * 2 / ( 1 - 5 ) ^ 2 ^ 3"
rpn_expr = shunting_yard infix_expression
p rpn_expr
p eval_rpn_expression(rpn_expr) { |op, operands|
  if operands.all? {|operand| operand =~ IDENTIFIER_REGEXP }
    eval(operands.insert(1, SPECIAL_RUBY_OPERATORS_MAPS[op] || op).join(' ')).to_s
  else
    "( #{op} #{operands.join(' ')} )"
  end
}
