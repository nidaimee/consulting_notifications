class AddPhotosJob < ApplicationJob
  def perform(client, photos)
    photos.each do |photo|
      client.photos.attach(photo)
    end
  end
end
