require "test_helper"
require "../lexer/lexer"

class LexerTest2 < Test::Unit::TestCase
    def test_while
        assert_equal [[:WHILE, "while"]], Lexer.new.tokenize("while")
    end
    def test_lbrace
        assert_equal [["{", "{"]], Lexer.new.tokenize("{")
    end
    def test_rbrace
        assert_equal [["}", "}"]], Lexer.new.tokenize("}")
    end
end