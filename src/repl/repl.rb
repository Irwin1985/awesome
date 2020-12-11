# repl para awesome
#
# Uso:
# awesome ecample.awm   # para evaluar un fichero awesome.
# awesome               # para iniciar el REPL de awesome
#

require "./interpreter/interpreter"
require "readline"

interpreter = Interpreter.new

# Si un fichero es dado entonces lo evaluamos.
if file = ARGV.first
    interpreter.eval File.read(file)
else # iniciamos el REPL 
    puts "Awesome REPL, CTRL+C to quit"
    loop do
        line = Readline::readline(">> ")        # 1. Read
        Readline::HISTORY.push(line)
        value = interpreter.eval(line)          # 2. Eval
        puts "=> #{value.ruby_value.inspect}"   # 3. Print
    end                                         # 4. Loop
end