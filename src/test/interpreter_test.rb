require "test_helper"
require "../interpreter/interpreter"

class InterpreterTest < Test::Unit::TestCase
    def test_number
        assert_equal 1, Interpreter.new.eval("1").ruby_value
    end

    def test_true
        assert_equal true, Interpreter.new.eval("true").ruby_value
    end

    # def test_assign
    #     assert_equal 2, Interpreter.new.eval("a = 2; 3; a").ruby_value
    # end
end