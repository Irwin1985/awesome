require "test_helper"
require "../runtime/object.rb"
require "../runtime/class.rb"
require "../runtime/method.rb"
require "../runtime/context.rb"
require "../runtime/bootstrap.rb"

class RuntimeTest < Test::Unit::TestCase
    def test_get_constant
        assert_not_nil Constants["Object"]
    end

    def test_create_an_object
        assert_equal Constants["Object"], Constants["Object"].new.runtime_class
    end

    def test_create_an_object_mapped_to_ruby_value
        assert_equal 32, Constants["Number"].new_with_value(32).ruby_value
    end

    def test_lookup_method_in_class
        assert_not_nil Constants["Object"].lookup("print")
        assert_raise(RuntimeError) { Constants["Object"].lookup("non-existant")}
    end   

    def test_call_method
        # simula un object.new en el lenguaje.
        object = Constants["Object"].call("new")

        assert_equal Constants["Object"], object.runtime_class
    end

    def test_a_class_is_a_class
        assert_equal Constants["Class"], Constants["Number"].runtime_class
    end
end