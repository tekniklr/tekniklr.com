Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 5.minutes

if Rails.env.development?
  Delayed::Job.where(attempts: 0).each do |job|
    job.destroy
  end
end