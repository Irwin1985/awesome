# --------------------------------------------------------------------------------
#                               Formato del Bytecode
# OpCode        Operandos                       Pila Antes          Pila Despues
# --------------------------------------------------------------------------------
PUSH_NUMBER = 0 # Número a ingresar en la pila      []                  [number]
PUSH_SELF   = 1 #                                   []                  [self]
CALL        = 2 # Método, Num. argumentos           [receptor, args]    [result]
RETURN      = 3 