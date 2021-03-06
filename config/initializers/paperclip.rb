# frozen_string_literal: true

# Paperclip interpolator for the attachment path, e.g. public/system
Paperclip.interpolates :attachment_path do |_attachment, _style|
  Rails.root.join Settings.attachment_storage
end

# Paperclip interpolator for the attachment url, e.g. system
Paperclip.interpolates :attachment_url do |_attachment, _style|
  # Remove 'public' from the attachment storage path
  Settings.attachment_storage.sub(/^public/, '')
end

# Paperclip interpolator for the instance's provider ID attribute
Paperclip.interpolates :provider_id do |attachment, _style|
  attachment.instance.provider_id
end

# Paperclip interpolator for the instance's external ID attribute
Paperclip.interpolates :external_id do |attachment, _style|
  attachment.instance.external_id
end

# Paperclip interpolator for the instance's version ID attribute
Paperclip.interpolates :version_id do |attachment, _style|
  attachment.instance.version_id
end

# Set the path for registering attachment styles
Paperclip.registered_attachments_styles_path =
  Rails.root.join(Settings.attachment_storage, 'paperclip_attachments.yml')
