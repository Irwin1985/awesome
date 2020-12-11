class AwesomeObject
    # Cada objeto tiene una clase llamada `runtime_class` para prevenir conflictos 
    # con la clase de ruby llamada `class`. Opcionalmente un objeto puede contener un valor
    # equivalente en ruby, ej: Los números y los strings almacenarán su valor ruby equivalente.
    attr_accessor :runtime_class, :ruby_value

    def initialize(runtime_class, ruby_value=self)
        @runtime_class = runtime_class
        @ruby_value = ruby_value
    end

    # Al igual que el modelo runtime basado en clases, almacenamos los métodos en las clases
    # de los objetos. Cuando se llame un método de un objeto, necesitamos primero buscar
    # el método en la clase y luego invocarlo.
    def call(method, arguments=[])
        @runtime_class.lookup(method).call(self, arguments)
    end
end