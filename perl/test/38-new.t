use Lingy::Test;

tests <<"...";
- - (macroexpand '(Foo.Bar. 123))
  - (. Foo.Bar new 123)
# - - (require Foo.Space)
#   - Foo.Class
# - - (XXX (.new Foo.Class 42 43 44 45))
#   - xxx
...
