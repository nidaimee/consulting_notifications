Sidekiq::Cron::Job.create(
  name: "Notify Clients every 2 weeks",
  cron: "0 9 */14 * *", # Todo dia 0 a cada 14 dias às 09:00
  class: "NotifyClientsJob"
)
