class TrimLinksController < ApplicationController
  before_action :authenticate_user!

  # POST /trim_links
  # POST /trim_links.json
  def create
    accepted_formats = [".tr5"]

    uploaded_io = trim_link_params[:file_data]
    filename = uploaded_io.original_filename

    if accepted_formats.include? File.extname(filename)
      data = uploaded_io.read
      size = data.size

      @trim_link = TrimLink.new(:data => data, :filename => filename, :size => size, :pq_id => trim_link_params[:pq_id])

      if @trim_link.save
        redirect_to dashboard_url, notice: 'Trim link was successfully created.'
      else
        redirect_to dashboard_url, notice: "Could not add Trim link. #{@trim_link.errors}"
      end
    else
      flash[:error] = "Could not add Trim link. File must be tr5"
      redirect_to dashboard_url
    end
  end

  def show
    @upload = TrimLink.find(params[:id])
   
    @data = @upload.data
    send_data(@data, :type => 'application/octect-stream', :filename => @upload.filename, :disposition => 'download')
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def trim_link_params
      params.require(:trim_link).permit(:file_data, :pq_id)
    end
end
