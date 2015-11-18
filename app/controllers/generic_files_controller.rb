class GenericFilesController < ApplicationController

  STILL_IMAGE_TYPES = [
    "application/pdf",
    "image/jpeg",
    "image/png",
    "image/tiff",
    "image/vnd.adobe.photoshop",
  ]

  TEXT_TYPES = [
    "application/msword",
    "application/pdf",
    "application/rtf",
    "application/vnd.ms-powerpoint",
    "application/vnd.oasis.opendocument.text",
    "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "image/jpeg",
    "image/png",
    "image/tiff",
    "text/html",
    "text/markdown",
    "text/plain",
  ]


  include Sufia::Controller
  include Sufia::FilesControllerBehavior

  self.presenter_class = AssetPresenter
  self.edit_form_class = AssetEditForm

  before_filter :require_asset_type, only: [:create]
  before_filter :verify_asset_type, only: [:create]
  before_filter :verify_mime_type, only: [:create]

  def require_asset_type
    return json_error("You must provide an asset type") unless params.has_key? :asset_type
  end

  def verify_asset_type
    return json_error("Asset type must be either still_image or text") unless params[:asset_type].match(/still_image|text/)
  end

  def update_metadata_from_upload_screen
    super
    @generic_file.assert_still_image if params[:asset_type].match("still_image")
    @generic_file.assert_text        if params[:asset_type].match("text")
  end

  def verify_mime_type
    if params[:asset_type].match("still_image")
      params["files"].each do |file|
        if MIME::Types.of(file.original_filename).empty?
          return_unknown_mime_type
        else
          reject_still_image_types unless STILL_IMAGE_TYPES.include?(MIME::Types.of(file.original_filename).first.content_type)
        end
      end
    end
    if params[:asset_type].match("text")
      params["files"].each do |file|
        if MIME::Types.of(file.original_filename).empty?
          return_unknown_mime_type
        else
          reject_text_types unless TEXT_TYPES.include?(MIME::Types.of(file.original_filename).first.content_type)
        end
      end
    end
  end

  def reject_still_image_types
    return json_error("Submitted file does not have a mime type for a still image")
  end

  def reject_text_types
    return json_error("Submitted file does not have a mime type for a text file")
  end

  def return_unknown_mime_type
    return json_error("Submitted file is an unknown mime type")
  end

end
