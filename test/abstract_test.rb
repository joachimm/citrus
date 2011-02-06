require File.expand_path('../helper', __FILE__)

class AbstactTest < Test::Unit::TestCase
  def test_terminal?
    rule = Abstract.new
    assert_equal(false, rule.terminal?)
  end

  def test_exec
  
    abstract = Grammar.new do
      rule :unit do
        all('[',:unimplemented,']')
      end
      abstract_rule :unimplemented
    end
    
    grammar = Grammar.new {
      include abstract
      root :top
      rule :top, :unit
      rule :unimplemented, "@"
      resolve_abstract_rules
    }

    match = grammar.parse('[@]')
    
    assert(match)
    assert_equal('[@]', match)
    assert_equal(3, match.length)

  end
end
