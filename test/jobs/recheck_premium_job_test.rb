require 'test_helper'

class RecheckPremiumJobTest < ActiveJob::TestCase
  test "recheck users whose premium has just expired" do
    freeze_time do
      user_1 = create :user, premium_until: Time.current - 1.minute
      user_2 = create :user, premium_until: Time.current - 1.hour
      user_3 = create :user, premium_until: Time.current - 1.day
      user_4 = create :user, premium_until: Time.current - 2.days

      # Ignore user without premium
      create :user, premium_until: nil

      # Ignore users which premium has not expired
      create :user, premium_until: Time.current + 1.day
      create :user, premium_until: Time.current + 1.week
      create :user, premium_until: Time.current + 1.month
      create :user, premium_until: Time.current + 1.year

      # Ignore users which premium has expired a while ago
      create :user, premium_until: Time.current - 3.days
      create :user, premium_until: Time.current - 1.week
      create :user, premium_until: Time.current - 1.month
      create :user, premium_until: Time.current - 1.year

      User::Premium::Expire.expects(:call).with(user_1).once
      User::Premium::Expire.expects(:call).with(user_2).once
      User::Premium::Expire.expects(:call).with(user_3).once
      User::Premium::Expire.expects(:call).with(user_4).once

      perform_enqueued_jobs do
        RecheckPremiumJob.perform_now
      end
    end
  end
end
