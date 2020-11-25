class ApplicationMailer < ActionMailer::Base
  default from: "The Exercism Team <hello@mail.exercism.io>", reply_to: "hello@exercism.io"

  layout "mailer"
end
