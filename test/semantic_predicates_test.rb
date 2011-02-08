require File.expand_path('../helper', __FILE__)
require 'set'
class SemanticPredicateTest < Test::Unit::TestCase
  class Context
    attr_accessor :first
  end
  
  
  def test_exec
  
    grammar = Grammar.new do
      rule :unit do
        rep(all(:expr, ';')){
          matches.map{|e| [:expr, e.expr.value]}
        }
      end
      
      rule :expr do
        any(:assign,:symbol){
          first.value
        }
      end
      
      rule :assign do
       semp(all(:var,'=',:symbol){[:assign, var.matches[0].value, symbol.value]},false) do |o,m|
         o[m.var.to_s]=m.symbol.to_s
         true
       end
      end
      rule :symbol do
        any(:method, :var){
          first.value
        }
      end
      
      rule :method do
        semp all(:var){ [:method, var.to_s]}, false do |c, m|
          return false if c.has_key? m.var.to_s
          true
        end
      end
      
      rule :var do
      semp any(/\b[a-z]+\b/){[:var, to_s]} , false do
        true
      end
        
      end
      root :unit
    end

    c = {'k'=>:true}
    match = grammar.parse('k;aa=b;ac=d;ua;ub;ac;', {:context => c})
    assert(match)
    assert_equal(match, 'k;aa=b;ac=d;ua;ub;ac;')
    assert_equal(
      [[:expr, [:var, "k"]],
      [:expr, [:assign, [:var,"aa"], [:method, "b"]]],
      [:expr, [:assign, [:var,"ac"], [:method, "d"]]],
      [:expr, [:method, "ua"]],
      [:expr, [:method, "ub"]],
      [:expr, [:var, "ac"]]],
     match.value )
    
  end
  
  def test_semantic_predicate
  
    grammar = Grammar.new do
      rule :unit do
        all(:first, ' ', :second){
          puts captures.inspect
        }
      end
      rule :first do
       semp(:var, false) do |c,m|
         c.first = m.to_s
       end
      end

      rule :second do
       semp(:var, true) do |c,r|
         'fail' != c.first
       end
      end

      rule :var do
        all(/[a-z]+/){
          [:var, to_s]
        }
      end
      root :unit
    end
    context = Context.new
    match = grammar.parse('a b', {:context => context})
    assert(match)
    assert_equal('a b', match)
    assert_equal(3, match.length)
    assert_equal('a', context.first)

    context = Context.new
    assert_raise Citrus::ParseError do
      match = grammar.parse('fail a', {:context => context})
    end
  end
  
end
