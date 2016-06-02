require "zeus/rails"

class CustomPlan < Zeus::Rails
  def test(*args)
    ENV["GUARD_RSPEC_RESULTS_FILE"] = "tmp/guard_rspec_results.txt"
    super
  end
end

Zeus.plan = CustomPlan.new
