threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

port ENV.fetch("PORT", 3000)

# IMPORTANTE: Bind to all interfaces for Render
bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3000)}"

environment ENV.fetch("RAILS_ENV", "development")

plugin :tmp_restart
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

if ENV["RAILS_ENV"] == "production"
  workers ENV.fetch("WEB_CONCURRENCY", 1)
  preload_app!
end
