class ImportController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :load_service

  def question
    import_result = @importService.questions_by_uin(params[:uin])
    @questions = import_result[:questions]
    @errors = import_result[:errors]

    render :partial => 'questions_import'
  end

  def questions
    dateTo = DateTime.parse(params[:dateTo])
    dateFrom = DateTime.parse(params[:dateFrom])
    @import_result = @importService.questions(dateFrom: dateFrom, dateTo: dateTo)

    render :partial => 'questions_import'
  end

  def questions_async
    ImportWorker.perform_async

    @import_result = 'Run async ok'
    render :partial => 'questions_import'
  end

  def questions_force_update
    dateTo = DateTime.parse(params[:dateTo])
    dateFrom = DateTime.parse(params[:dateFrom])
    @import_result = @importService.questions_no_lock(dateFrom: dateFrom, dateTo: dateTo)

    render :partial => 'questions_import'
  end

  def questions_no_log
    importService_no_log = ImportService.new

    dateTo = DateTime.parse(params[:dateTo])
    dateFrom = DateTime.parse(params[:dateFrom])
    import_result = importService_no_log.questions(dateFrom: dateFrom, dateTo: dateTo)

    @questions = import_result[:questions]
    @errors = import_result[:errors]

    render :partial => 'questions_import'
  end


  def logs
    @logs = ImportLog.all
    render :partial => 'import_log'
  end


  protected

  def load_service(importService = ImportServiceWithDatabaseLock.new)
    @importService ||= importService
  end
end