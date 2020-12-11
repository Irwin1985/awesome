class AwesomeMethod
    def initialize(params, body)
        @params = params
        @body = body
    end

    def call(receiver, arguments)
        # Crea un contexto de evaluación en el cual el método será ejecutado.
        context = Context.new(receiver)

        # Asigna los parámetros a variables locales
        @params.each_with_index do |param, index|
            context.locals[param] = arguments[index]
        end

        # El body es un nodo (creado en el parser)
        # El método eval del body
        @body.eval(context)
    end
end