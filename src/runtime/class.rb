# Las clases son objetos en Awesome por lo tanto heredan de AwesomeObject.
class AwesomeClass < AwesomeObject
    attr_reader :runtime_methods

    def initialize
        @runtime_methods = {}
        @runtime_class = Constants["Class"]
    end

    # Lookup a method => Buscar un método.
    def lookup(method_name)
        method = @runtime_methods[method_name]
        raise "Method not found: #{method_name}" if method.nil?
        method
    end

    # Método helper para definir un método en esta clase desde Ruby.
    def def(name, &block)
        @runtime_methods[name.to_s] = block
    end

    # Crea una nueva instancia de esta clase
    def new
        AwesomeObject.new(self)
    end

    # Crea una instancia de esta clase que contiene un valor ruby.
    def new_with_value(value)
        AwesomeObject.new(self, value)
    end
end