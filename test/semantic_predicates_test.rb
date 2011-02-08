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
       sem_pre(all(:var,'=',:symbol){[:assign, var.value, symbol.value]},false) do |o,m|
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
        sem_pre(ext(:var){ [:method, var.to_s]}, false){ |c, m|
          return false if c.has_key? m.var.to_s
        }
      end
      
      rule :var do
        all(/[a-z]+/){
          [:var, to_s]
        }
      end
      root :unit
    end

    c = {}
    match = grammar.parse('aa=b;c=d;a;b;c;', {:context => c})
    assert(match)
    assert_equal(match, 'aa=b;c=d;a;b;c;')

    match = grammar.parse('a=b;c=d;', {:context => {}})
    assert(match)
    assert_equal('a=b;c=d;', match)

    
  end
  
  def test_semantic_predicate
  
    grammar = Grammar.new do
      rule :unit do
        all(:first, ' ', :second){
          puts captures.inspect
        }
      end
      rule :first do
       sem_pre(:var, false) do |c,m|
         c.first = m.to_s
       end
      end

      rule :second do
       sem_pre(:var, true) do |c,r|
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
