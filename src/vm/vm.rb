require "./bytecode/bytecode"
require "./runtime/object.rb"
require "./runtime/class.rb"
require "./runtime/method.rb"
require "./runtime/context.rb"
require "./runtime/bootstrap.rb"

class VM
    def run(bytecode)
        # Primero creamos la pila para pasar valores entre instrucciones.
        # incializamos el puntero de instrucciones o `ip` el cual contiene el índice
        # de la instrucción que está siendo ejecutada en `bytecode`
        stack = []
        ip = 0

        # Luego entramos en un loop donde avanzaremos un byte a la vez en el `bytecode`
        # el primer byte es el opCode.
        while true
            case bytecode[ip] # Inspeccionamos el byte actual, este será el opCode.
            when PUSH_NUMBER
                ip += 1 # avanzamos al siguiente byte (el operando)
                value = bytecode[ip] # Leemos el operando.

                stack.push Constants["Number"].new_with_value(value)

            # Como `self` se usa en todas partes, entonces creamos una instrucción.
            when PUSH_SELF
                stack.push RootContext.current_self

            # La instrucción más compleja de la VM es `CALL`
            # tiene 2 operandos y espera que se hagan varias cosas en la pila.
            when CALL
                ip += 1 # El siguiente byte contiene el método a llamar.
                method = bytecode[ip]

                ip += 1 # El siguiente byte contiene el número de args.
                argc = bytecode[ip]

                # En este punto tanto el receptor como los argumentos ya estarían
                # cargados en la pila.
                args = []
                argc.times do
                    args << stack.pop
                end
                receiver = stack.pop

                # usando estos valores hacemos la llamada.
                stack.push receiver.call(method, args)
            
                # Aquí salimos del loop. Cada programa debe finalizar con esta instrucción.
            when RETURN
                return stack.pop # La última instrucción cargada en la pila.
            end
            # Finalmente avanzamos el puntero un byte más al siguiente operando.
            ip += 1
        end
    end 
end