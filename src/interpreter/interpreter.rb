require "./parser/parser"
require "./runtime/object"
require "./runtime/class"
require "./runtime/method"
require "./runtime/context"
require "./runtime/bootstrap"

# Primero creamos una clase envoltorio simple para encapsular el proceso de interpretación.
# todo lo que hace es analizar el código y llamar al `eval` del nodo root.
class Interpreter
    def initialize
        @parser = Parser.new
    end

    def eval(code)
        @parser.parse(code).eval(RootContext)
    end
end

# La clase `Nodes` estará siempre en la cima del AST. Su único propósito es contener
# los otros nodos. Es el equivalente a `Program` en Monkey ast.
#
# El método `eval` de cada nodo es el interpretador del lenguaje.
# todos los nodos saben como evaluarse a sí mismos y retornar el resultado
# de su evaluación.
#
# La variable `context` es el Environment donde se ejecutarán los nodos
# variables locales, self y class.
class Nodes
    def eval(context)
        return_value = nil
        nodes.each do | node |
            return_value = node.eval(context)
        end
        return_value || Constants["nil"] # La última expresión evaluada o por defecto `nil`
    end
end

# A continuación se implementa el método `eval` de cada nodo. 
class NumberNode
    def eval(context)
        Constants["Number"].new_with_value(value)
    end
end

class StringNode
    def eval(context)
        Constants["String"].new_with_value(value)
    end
end

class TrueNode
    def eval(context)
        Constants["true"]
    end
end

class FalseNode
    def eval(context)
        Constants["false"]
    end
end

class NilNode
    def eval(context)
        Constants["nil"]
    end
end

class GetConstantNode
    def eval(context)
        Constants[name]
    end
end

class GetLocalNode
    def eval(context)
        context.locals[name]
    end
end

# El contenido de `value` dentro de las clases `Local` o `Constant`
# es un nodo también, por lo tanto hay que evaluarlo para obtener su valor.
class SetConstantNode
    def eval(context)
        Constants[name] = value.eval(context)
    end
end

class SetLocalNode
    def eval(context)
        context.locals[name] = value.eval(context)
    end
end

# El nodo `CallNode` es más complejo porque primero tiene que asignar el receptor
# y luego evaluar los argumentos antes de llamar al método.

class CallNode
    def eval(context)
        if receiver
            value = receiver.eval(context)
        else
            value = context.current_self # Se va por defecto a `self`
        end

        evaluated_arguments = arguments.map {|arg| arg.eval(context)}
        value.call(method, evaluated_arguments)
    end
end

# Definir un método con `def`
class DefNode
    def eval(context)
        method = AwesomeMethod.new(params, body)
        context.current_class.runtime_methods[name] = method
    end
end

# Definir una clase se hace en 3 pasos
#
# 1. Definir la clase
# 2. Crear un contexto de evaluación.
# 3. Evaluar el cuerpo de la clase dentro del contexto.

class ClassNode
    def eval(context)
        awesome_class = Constants[name] # Revisa si la clase ya está definida.

        unless awesome_class # la clase no existe todavía.
            awesome_class = AwesomeClass.new
            Constants[name] = awesome_class
        end

        class_context = Context.new(awesome_class, awesome_class)
        body.eval(class_context)

        awesome_class
    end
end

# Finalizamos con la estructura de control `if`
class IfNode
    def eval(context)
        if condition.eval(context).ruby_value
            body.eval(context)
        else # Si no es verdad entonces `nil` porque no hay `else` xD
            Constants["nil"]
        end
    end
end