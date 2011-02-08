require File.expand_path('../helper', __FILE__)

class SemanticPredicateTest < Test::Unit::TestCase
  def test_exec
  
    grammar = Grammar.new do
      rule :unit do
        rep(all( any(:assign,:symbol), ';')){
          puts captures.inspect
        }
      end
      rule :assign do
       sem_pre(all(:var,'=',:symbol),false) do |o,m|
         puts o.inspect
         puts m.var.inspect
         true
       end
      end
      rule :symbol do
        any(:var)
      end
      
      rule :var do
        all(/[a-z]+/){
          [:var, to_s]
        }
      end
      root :unit
    end


    match = grammar.parse('a=b;')
    assert(match)
    assert_equal('a=b;', match)
    assert_equal(4, match.length)

    match = grammar.parse('a=b;c=d;')
    assert(match)
    assert_equal('a=b;c=d;', match)


  end
end
