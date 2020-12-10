require '../lexer/lexer'

code = <<-CODE
if 1:
  if 2:
    print("...")
    if false:
      pass
    print("done!")
  2
print "The End"
CODE

l = Lexer.new().tokenize(code)
puts(l)