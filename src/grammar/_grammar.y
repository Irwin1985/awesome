class Parser
# Necesitamos decirle al Parser cuáles son los tokens que debe esperar. Por lo tanto cada
# tipo de token debe ser definido aquí también.
token IF
token DEF
token CLASS
token NEWLINE
token NUMBER
token STRING
token TRUE FALSE NIL
token IDENTIFIER
token CONSTANT
token INDENT DEDENT

# Ahora necesitamos definir la tabla de precedencias para los operadores. Esto le dice al Parser
# en cuál orden se deben ejecutar las expresiones que contengan operadores.
# Esta tabla está basada en la tabla de precedencias del lenguaje `C`.

prechigh
  left '.'
  right '!'
  left '*' '/'
  left '+' '-'
  left '>' '>=' '<' '<='
  left '==' '!='
  left '&&'
  left '||'
  right '='
  left ','
preclow

# A continuación definiremos las reglas de análisis
# Todas las reglas deben declararse con el siguiente formato:
#
#   NombreRegla:
#       Regla1  TOKEN Regla2 { result = Node.new }
#     | Regla3               { ... }
#     ;
#
# En la sección de la acción (dentro de las llaves `{acción}`) a la derecha) puedes hacer:
#
# * Asignar a `result` el valor retornado por la regla, usualmente un ast Node.
# * usar directamente `val[indice]` para obtener el resultado `result` que hizo match
#   en la expresión de la izquierda.

rule
  # Para empezar, los Parsers son tontos así que necesitamos decirles explícitamente como
  # tratar con programas vacíos. Esto es lo que la primera regla hace. Cualquer contenido
  # dentro de `/*` y `*/` será ignorado.
  Program:
    /* no hagas nada */                     { result = Nodes.new([]) }
    | Expressions                           { result = val[0] }
    ;
  
  # A continuación definimos una lista de expresiones. Es una serie de expresiones separadas
  # por un delimitador (un salto de línea o un `;`). Pero nuevamente debemos indicarle al Parser
  # cómo debe gestionar las listas vacías o saltos de línea.
  #
  # Usaremos la recursividad por la izquierda ya que es la que nos permite el tipo de parser LR.
  #
  # Las expresiones serán recursivas ya que una expresión puede contener otras expresiones.
  Expressions:
    Expression                              { result = Nodes.new(val) }
  | Expressions Terminator Expression       { result = val[0] << val[2] }
  | Expressions Terminator                  { result = val[0] }
  | Terminator                              { result = Nodes.new([]) }
  ;

  # Cada expresión del lenguaje será definida aquí:
  Expression:
    Literal
  | Call
  | Operator
  | GetConstant
  | SetConstant
  | SetLocal
  | Def
  | Class
  | If
  | '(' Expression ')'                  { result = val[1] }
  ;

  # Al usar parentesis estamos forzando al analisis de la expresión en primer lugar.
  #
  # Los terminadores son tokens que terminan una expresión.
  # Cuando se usan tokens para definir reglas, simplemente los referimos a ellos 
  # por su tipo definido previamente por el lexer.
  Terminator:
    NEWLINE
  | ";"
  ;

  # Los literales son valores `hard-coded` dentro del programa.
  Literal:
    NUMBER                              { result = NumberNode.new(val[0]) }
  | STRING                              { result = StringNode.new(val[0]) }
  | TRUE                                { result = TrueNode.new }
  | FALSE                               { result = FalseNode.new }
  | NIL                                 { result = NilNode.new }
  ;

  # Las llamadas a métodos pueden tomar 3 formas:
  #
  # 1. Sin receptor (se asume `self`): `metodo(argumentos)`.
  # 2. Con receptor: `receptor.metodo(argumentos)`.
  # 3. Y un poco de azucar sintáctica es: si el método no tiene argumentos
  #    entonces lo podemos invocar sin paréntesis: `receptor.metodo`
  #
  # Cada caso se define a continuación:
  
  Call:
    IDENTIFIER Arguments                { result = CallNode.new(nil, val[0], val[1]) }
  | Expression "." IDENTIFIER
    Arguments                           { result = CallNode.new(val[0], val[2], val[3]) }
  | Expression "." IDENTIFIER           { result = CallNode.new(val[0], val[2], []) }
  ;

  Arguments:
    "(" ")"                             { result = [] }
  | "(" ArgList ")"                     { result = val[1] }
  ;

  ArgList:
    Expression                          { result = val }
  | ArgList "," Expression              { result = val[0] << val[2] }
  ;

  # En nuestro lenguaje los operadores son convertidos en llamadas a métodos
  # ejemplo: `1 + 2` será `1.+(2)`.
  # donde `1` es el receptor de la llamada `+` pasando como argumento a `2`
  # Los operadores deben ser definidos de forma individual.

  Operator:
    Expression '||' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '&&' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '==' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '!=' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '>' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '>=' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<=' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '+' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '-' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '*' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '/' Expression          { result = CallNode.new(val[0], val[1], [val[2]]) }
  ;

  # Reglas para las Constantes globales y variables locales.
  GetConstant:
    CONSTANT                            { result = GetConstantNode.new(val[0]) }
  ;

  SetConstant:
    CONSTANT "=" Expression             { result = SetConstantNode.new(val[0], val[2]) }
  ;

  GetLocal:
    IDENTIFIER                          { result = GetLocalNode.new(val[0]) }
  ;

  SetLocal:
    IDENTIFIER "=" Expression           { result = SetLocalNode.new(val[0], val[2]) }
  ;

  # Nuestro lenguaje usará identación para separar los bloques de código. El Lexer ya 
  # se encargó de eso y nos devolvió los tokens INDENT y DEDENT respectivamente. Por lo tanto
  # un bloque de código es simplemente un incremento de INDENT seguido por algún código y 
  # finalizado con un DEDENT equivalente al IDENT de inicio.
  #
  Block:
    INDENT Expressions DEDENT           { result =val[1] }
  ;

  # La palabra reservada `def` es usada para definir métodos. De igual forma se suprimen 
  # los paréntesis cuando el método no necesite argumentos.
  Def:
    DEF IDENTIFIER Block                { result = DefNode.new(val[1], [], val[2]) }
  | DEF IDENTIFIER
    "(" ParamList ")" Block             { result = DefNode.new(val[1], val[3], val[5]) }
  ;

  ParamList:
    /* Nada */                          { result = [] }
  | IDENTIFIER                          { result = val }
  | ParamList "," IDENTIFIER            { result = val[0] << val[2] }
  ;

  # La definición de una clase es similar a la de un método.
  # Las clases son también constantes porque ellas comienzan con mayúscula.
  Class:
    CLASS CONSTANT Block                { result = ClassNode.new(val[1], val[2]) }
  ;

  # Finalmente la estructura de control `if` es similar a `class` pero recibe una condicion.
  If:
    IF Expression Block                 { result = IfNode.new(val[1], val[2]) }
  ;
end

# Puedes colocar código en el (`header`) y también dentro de la clase (`inner`).
---- header
  # carambas me gusta ruby pana. :)
  require "../lexer/lexer"
  require "../node/nodes"

---- inner
  def parse(code, show_tokens=false)
    @tokens = Lexer.new.tokenize(code) # Crea los tokens usando el Lexer.
    puts @tokens.inspect if show_tokens
    do_parse # Arranca el proceso de análisis.
  end

  def next_token
    @tokens.shift
  end