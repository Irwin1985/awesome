# Este primer tipo es responsable de contener una colección de nodos,
# cada uno representando una expresión. Piensa en él como si fuera una
# representación interna de un bloque de código.

# Definiremos los nodos como clases que heredan de `Struct`. Esta es una forma
# sencilla de crear una clase que contiene atributos (valores).
class Nodes < Struct.new(:nodes)
    def <<(node) # Método útil para agregar nodos al vuelo.
        nodes << node
        self
    end
end

# Los literales son valores estáticos que tienen una representación en Ruby. Por ejemplo
# un string un número, `true`, `false`, `nil`, etc. Definimos un nodo para cada uno de ellos
# y almacenamos su representación dentro de su atributo `value`.

class LiteralNode < Struct.new(:value); end

class NumberNode < LiteralNode; end

class StringNode < LiteralNode; end

class TrueNode < LiteralNode
    def initialize
        super(true)
    end
end

class FalseNode < LiteralNode
    def initialize
        super(false)
    end
end

class NilNode < LiteralNode
    def initialize
        super(nil)
    end
end

# El tipo de nodo para una llamada a un método contedrá un receptor `receiver` que será 
# el objeto sobre el cuál el método es llamado. Ej: `object.method()`. También contendrá
# el nombre del método y sus argumentos que serán otros nodos.

class CallNode < Struct.new(:receiver, :method, :arguments); end

# El siguiente nodo recuperará el valor de una constante por su nombre.
class GetConstantNode < Struct.new(:name); end

# Y el siguiente nodo asignará un valor a una constante. El atributo `value` será un nodo.
# is almacenamos un numero entonces será un `NumberNode` etc.
class SetConstantNode < Struct.new(:name, :value); end

# De la misma forma actuarán estos nodos pero para variables locales.
class GetLocalNode < Struct.new(:name); end
class SetLocalNode < Struct.new(:name, :value); end

# Cada definición de un método será contenida en el siguiente nodo. Contendrá el nombre
# `name` del método, sus parámetros `params` y su bloque de código `body` que será evaluado
# cuando el método sea invocado.
class DefNode < Struct.new(:name, :params, :body); end

# La definición de las clases van en el siguiente nodo. Una vez más, el nombre `name`
# de la clase y su `body` serán un árbol de nodos.
class ClassNode < Struct.new(:name, :body); end

# la estructura de control `if` será también un nodo. La `condition` y el `body` también
# son nodos que serán evaluados en algún punto.
# Atención al funcionamiento de este nodo para poder crear más en el futuro.
class IfNode < Struct.new(:condition, :body); end