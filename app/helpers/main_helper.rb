module MainHelper
  
  # will generate the closest cromulent fade size for the current step
  # (in 10s, 0 - 100)
  def fade_level(num_steps, step)
    step_size = ((100/num_steps)/10).round * 10
    step * step_size
  end
  
end
