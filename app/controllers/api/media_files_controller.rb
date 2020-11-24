module Api
  class MediaFilesController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!

    def index
    	media_files = policy_scope(MediaFile)
      if params.has_key?(:media_type)
        media_files = media_files.where(media_type: params[:media_type])
      end

      if params.has_key?(:page)
        media_files = media_files.page(params[:page]).per(24)
      end

      meta = {
        total_pages: media_files.total_pages, 
        curr_page: media_files.current_page,
        prev_page: media_files.prev_page,
        next_page: media_files.next_page
        }
      
      render json: media_files, each_serializer: MediaFileSerializer, meta: meta
    end

    def create
      mf = MediaFile.new(user_id: params[:user_id])
      mf.media_type = "image"
      mf.image = params[:file]

      if mf.save
        if params.has_key?(:is_redactor)
          render json: mf, adapter: :attributes
        else
          render json: mf
        end
      else
        render json: {errors: mf.errors}, status: 500
      end

    end

    def destroy
      mf = MediaFile.find(params[:id])
      begin
        if mf.destroy
          render json: { message: "removed" }, status: :ok
        else
          render json: {errors: mf.errors}, status: 500
        end
      rescue ActiveRecord::InvalidForeignKey => e
        render json: {errors: "RecordStillReferenced"}, status: 500
      end
    end
  end
end