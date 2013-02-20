# encoding: utf-8
class AttachmentUploader < CarrierWave::Uploader::Base

  process :set_content_type

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    CarrierWave.configure do |config|
      if config.storage == :file
        return "uploads/#{Rails.env}/#{model.class.to_s.underscore}/#{model.id}"
      else
        if model.old?
          # legacy path for aws
          return "events/attachments/"+(model.parent.nil? ? model.id.to_s : model.parent.id.to_s)
        else
          return "#{Rails.env}/#{model.class.to_s.underscore}/#{model.id}"
        end
      end
    end
  end

  version :thumbnail do
    version :list do
      process :resize_to_fill => [100,100]
    end
    version :pageview do
      process :resize_to_fill => [300,300]
    end
    version :lightbox do
      process :resize_to_fill => [490,390]
    end
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

end
