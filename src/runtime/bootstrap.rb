# Primero creamos un hash donde almacenaremos todas las constantes accesibles
# desde el `runtime`. Luego lo poblamos con las clases core del lenguaje.
Constants = {}

Constants["Class"] = AwesomeClass.new # define la clase `class`
Constants["Class"].runtime_class = Constants["Class"] # asigna el tipo en `Class.class`
Constants["Object"] = AwesomeClass.new # define la clase `Object`
Constants["Number"] = AwesomeClass.new # define la clase `Number`
Constants["String"] = AwesomeClass.new # define la clase `String`

# El contexto raíz será el punto de inicio donde todos los programas
# comenzarán su evaluación.
root_self = Constants["Object"].new
RootContext = Context.new(root_self)

# Todo es un objeto, incluso `true`, `false` y `nil` por lo tanto necesitan una clase.
Constants["TrueClass"] = AwesomeClass.new
Constants["FalseClass"] = AwesomeClass.new
Constants["NilClass"] = AwesomeClass.new

Constants["true"] = Constants["TrueClass"].new_with_value(true)
Constants["false"] = Constants["FalseClass"].new_with_value(false)
Constants["nil"] = Constants["NilClass"].new_with_value(nil)

# Ahora tenemos que inyectarle todos estos objetos al `runtime`
# podemos definirle métodos a estos objetos.
#
# El primer método es `new` se lo definimos a la clase madre `class`
# para que todos sus hijos lo puedan usar.
Constants["Class"].def :new do |receiver, arguments|
    receiver.new
end

# el siguiente es `print` ya que puede usarse desde cualquier sitio
# teoricamente al hacer un `print` internamente es `self.print` donde
# self siempre será una instancia de `Object`.

Constants["Object"].def :print do |receiver, arguments|
    puts arguments.first.ruby_value
    Constants["nil"] # Siempre hay que retornar algo.
end

#