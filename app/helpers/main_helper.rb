module MainHelper
  
  # will generate the closest cromulent fade size for the current step
  # there are 15 total fade styles with gradually increasing transparency
  def fade_level(num_steps, step)
    num_steps = (num_steps > 15) ? 15 : num_steps
    step_size = ((150.to_f/num_steps)/10).round * 10
    step * step_size
  end
  
end
