class RemoveHistoryImagesJob < ApplicationJob
  queue_as :default

  def perform(image_keys)
    image_keys.each do |key|
      blob = ActiveStorage::Blob.find_by(key: key)
      blob&.purge
    end

    Rails.logger.info "Removed #{image_keys.count} images from storage"
  end
end
