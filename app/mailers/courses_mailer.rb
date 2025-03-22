class CoursesMailer < ApplicationMailer
  def front_end_fundamentals_enrolled
    @enrollment = params[:enrollment]

    subject = "🎓 Welcome to Front-End Fundamentals"
    @title = "Welcome to Front-End Fundamentals!"

    enrollment_mail(subject)
  end

  def coding_fundamentals_enrolled
    @enrollment = params[:enrollment]

    subject = "🎓 Welcome to Coding Fundamentals"
    @title = "Welcome to Coding Fundamentals!"

    enrollment_mail(subject)
  end

  def bundle_coding_front_end_enrolled
    @enrollment = params[:enrollment]

    subject = "🎓 Welcome to the Exercism Bootcamp"
    @title = "Welcome to the Exercism Bootcamp!"

    enrollment_mail(subject)
  end

  private
  def enrollment_mail(subject)
    if @enrollment.user
      @user = @enrollment.user
      transactional_mail(@user, subject)
    else
      mail_to_email(@enrollment.email, subject)
    end
  end
end
