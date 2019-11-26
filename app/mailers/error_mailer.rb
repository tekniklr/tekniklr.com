class ErrorMailer < ApplicationMailer
  
  # regular errors are captured by exception notifier - handle rescued/etc
  # errors separately here

  def background_error(message, exception)
    @message = message
    @exception = exception
    mail(
      to:      'rails@tekniklr.com',
      subject: "[tekniklr.com] background error"
    )
  end
  
end