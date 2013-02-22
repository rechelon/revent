# encoding: utf-8
class AttachmentUploader < CarrierWave::Uploader::Base
  process :set_metadata
  include CarrierWave::RMagick

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

  def set_metadata
    model.content_type = @file.content_type
    if self.is_image?
      img = Magick::Image::read(@file.file).first
      model.width = img.columns
      model.height = img.rows
    end
    model.size = @file.size.inspect
  end

  version :thumbnail, :if => :is_image? do
    version :list do
      process :resize_to_fit => [100,100]
    end
    version :pageview do
      process :resize_to_fit => [300,300]
    end
    version :lightbox do
      process :resize_to_fit => [490,390]
    end
  end

  def is_image? file=nil
    model.image?
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

end
