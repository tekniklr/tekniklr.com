class ErrorMailer < ApplicationMailer
  
  # regular errors are captured by exception notifier - handle rescued/etc
  # errors separately here

  def background_error(message, exception, extra_message: nil)
    @message = message
    @exception = exception
    @extra_message = extra_message
    mail(
      to:      'rails@tekniklr.com',
      subject: "[tekniklr.com] background error #{@message}"
    )
  end
  
end