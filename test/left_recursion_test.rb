require File.expand_path('../helper', __FILE__)

class LeftRecursionTest < Test::Unit::TestCase
  grammar :LR do
    rule :expr do
      any(all(:expr, '-', :num),:num)
    end

    rule :num do
      /[0-9]+/
    end
  end
  
  def test_lr
    match = LR.parse("3-4-5", {:memoize=>true})
    assert(match)
    assert_equal("3-4-5", match)
  end
end