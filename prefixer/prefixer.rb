OPERANDS_REGEXP = /^[+-]?\d+|\w+$/
CONSTANT_REGEXP = /^[+-]?\d+$/
OPERATOR_REGEXP = /[+-\\*\\%\/^]/
OPERANDS_COUNT = 2

OPERATOR_PRECEDENCES = Hash.new(0).merge({ '^' => 5, '*' => 3,  '/' => 3, '%' => 3, '+' => 2, '-' => 2 })

def ident? token
  token.match /\d+|\w+/
end

OPERATORS = %w(+ - * / % ! ^)
SPECIAL_RUBY_OPERATORS_MAPS = { "^" => "**" }

def opertaor? token
  OPERATORS.include? token
end

module Enumerable
  def pop_to n, dest, &block
    block ||= lambda {|a| a.reverse }
    dest.push *block.call(self.pop(n))
  end
end

def shunting_yard infix_expression
  output = []
  operation_stack = []

  infix_expression.split.each do |token|
    case token
    when '(' then operation_stack << token
    when ')' then
      # Need to remove from stack and push to output all operators before '('
      # And remove '(' from stack

      # detect '(' in stack
      last_open_brace_index = operation_stack.rindex('(')
      raise "Not valid input expression: non expected ')'" unless last_open_brace_index

      operators_count_after_open_brace = operation_stack.length - last_open_brace_index - 1

      operation_stack.pop_to operators_count_after_open_brace, output

      operation_stack.pop # Pop '('
    when OPERANDS_REGEXP then output << token
    when OPERATOR_REGEXP then
      # Find less preceds operators then current operator
      ops = operation_stack.reverse.take_while do |op|
        stack_operator_precedence = OPERATOR_PRECEDENCES[op]
        current_token_precedence = OPERATOR_PRECEDENCES[token]

        is_operator = op =~ OPERATOR_REGEXP

        is_operator && (current_token_precedence <= stack_operator_precedence)
      end

      # Push less preced operators to the output
      unless ops.empty?
        operation_stack.pop_to ops.length, output
      end

      # add operator to the operator stack
      operation_stack << token
    end
  end

  # Return output with all remain operators in stack
  output + operation_stack.reverse
end

def eval_rpn_expression expression, &visitor
  # Setup default visitor
  visitor ||= lambda {|op, operands| (operands << op).join(' ') }

  operands_stack = []
  expression.each do |token|
    case token
    when OPERANDS_REGEXP then
      operands_stack << token
    when OPERATOR_REGEXP then
      #take operators operands
      raise "Bad RPN Expression: expected #{OPERANDS_COUNT} operands for operator #{token} in #{expression}" if operands_stack.size < OPERANDS_COUNT

      operands = operands_stack.pop(OPERANDS_COUNT)
      result = visitor.call(token, operands)
      operands_stack << result
    end
  end

  raise "Bad RPN Expression: there are > 1 operands_stack without operators in #{expression}" if operands_stack.size > 1

  operands_stack.first
end

if __FILE__ ==  $0
  begin
    infix_output = lambda {|op, operands| "( #{operands.insert(1, op).join(' ')} )" }
    postfix_output = lambda {|op, operands| "#{operands.insert(2, op).join(' ')}" }
    prefix_output = lambda {|op, operands| "( #{operands.insert(0, op).join(' ')} )" }

    expression_simplifier_visitor_decorator = lambda{|output_format|
      lambda { |op, operands|
        #Check if operands simplest type: constants
        if operands.all? {|operand| operand =~ CONSTANT_REGEXP }
          eval(operands.insert(1, SPECIAL_RUBY_OPERATORS_MAPS[op] || op).join(' ')).to_s
        else
          if negative_constant = operands.index {|operand| operand =~ /^-/}
            operands[negative_constant] = output_format.call('-', [0, operands[negative_constant].to_i.abs])
          end

          output_format.call(op, operands)
        end
      }
    }

    require 'optparse'

    options = { :format => prefix_output }

    optparse = OptionParser.new do|opts|
      # Set a banner, displayed at the top
      # of the help screen.
      opts.banner = "Usage: ruby #{__FILE__} [options] file"

      opts.on( '-p', '--postfix', 'Postfix form output' ) do
        options[:format] = postfix_output
      end

      opts.on( '-i', '--infix', 'Infix form output' ) do
        options[:format] = infix_output
      end

      opts.on( '-r', '--reduce', 'Reduce all expressions' ) do
        options[:reduce] = true
      end
    end

    optparse.parse!

    expresion_visitor = options[:format]

    if options[:reduce]
      expresion_visitor = expression_simplifier_visitor_decorator.call(expresion_visitor)
    end


    filename = ARGV[0] || "expressions"
    infix_expressions = File.new(filename)

    infix_expressions.each_line do |infix_expression|
      infix_expression.strip!
      rpn_expression = shunting_yard infix_expression

      result = eval_rpn_expression(rpn_expression) {|op, operands|
        expresion_visitor.call(op, operands)
      }
      puts "#{infix_expression} becomes #{result}"
    end


    #rescue => e
    #  puts "ERRORS: #{e.message}"
  end
end
