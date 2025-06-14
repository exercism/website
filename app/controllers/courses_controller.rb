class CoursesController < ApplicationController
  layout 'courses'
  skip_before_action :authenticate_user!

  before_action :use_course!, only: %i[show start_enrolling enroll pay]
  before_action :use_enrollment!, except: %i[enrolled stripe_session_status]
  before_action :use_location!, only: %i[show start_enrolling enroll pay]
  before_action :setup_pricing!, only: %i[show start_enrolling enroll pay]
  before_action :use_quotes!, only: [:show]
  before_action :cache_public_action!, only: %i[show]

  def course_redirect
    if user_signed_in? && (current_user.bootcamp_attendee? || current_user.bootcamp_mentor?)
      redirect_to bootcamp_dashboard_url
    else
      redirect_to course_url(params[:course] || Courses::CodingFundamentals.instance.slug)
    end
  end

  def show
    return unless stale?(etag: @course)

    render action: @course.template_slug

    difference_in_seconds = Time.utc(2025, 4, 26, 12, 0o0, 0o0) - Time.current

    # Convert to days, hours, minutes, and seconds
    @days = (difference_in_seconds / (24 * 60 * 60)).to_i
    @hours = (difference_in_seconds % (24 * 60 * 60) / (60 * 60)).to_i
    @minutes = (difference_in_seconds % (60 * 60) / 60).to_i
    @seconds = (difference_in_seconds % 60).to_i
  end

  def testimonials
    use_testimonials!
  end

  def start_enrolling
    @name = @enrollment&.name.presence || current_user&.name
    @email = @enrollment&.email.presence || current_user&.email

    @course_or_bundle = params[:course_or_bundle].presence
    return unless !@course_or_bundle && @enrollment&.course_slug

    @course_or_bundle = @enrollment.course_slug == @course.slug ? "course" : "bundle"
  end

  def enroll
    course_slug = params[:course_or_bundle] == "course" ? @course.slug : @bundle.slug
    if @enrollment
      @enrollment.update!(
        name: params[:name],
        email: params[:email],
        course_slug:,
        country_code_2: @country_code_2
      )
    else
      @enrollment = CourseEnrollment.create!(
        user: current_user,
        name: params[:name],
        email: params[:email],
        course_slug:,
        country_code_2: @country_code_2
      )
      session[:enrollment_id] = @enrollment.id
    end

    redirect_to action: :pay
  end

  def pay
    redirect_to action: :start_enrolling unless @enrollment&.course_slug.present?
  end

  def stripe_create_checkout_session
    if Rails.env.production?
      stripe_price = @enrollment.stripe_price_id
    else
      stripe_price = "price_1QCjUFEoOT0Jqx0UJOkhigru"
    end

    # rubocop:disable Layout/LineLength
    session = Stripe::Checkout::Session.create({
      ui_mode: 'embedded',
      customer_email: @enrollment.email,
      customer_creation: "always",
      line_items: [{
        price: stripe_price,
        quantity: 1
      }],
      mode: 'payment',
      allow_promotion_codes: true,
      return_url: "#{courses_enrolled_url}?enrollment_uuid=#{@enrollment.uuid}&failure_path=#{course_pay_path(@enrollment.course_slug)}&session_id={CHECKOUT_SESSION_ID}"
    })
    # rubocop:enable Layout/LineLength

    render json: { clientSecret: session.client_secret }
  end

  def stripe_session_status
    session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @enrollment = CourseEnrollment.find_by!(uuid: params[:enrollment_uuid])

    if session.status == 'complete'
      @enrollment.update!(checkout_session_id: session.id)
      @enrollment.paid!
    end

    render json: {
      status: session.status,
      customer_email: session.customer_details.email
    }
  end

  def enrolled
    @enrollment = CourseEnrollment.find_by!(uuid: params[:enrollment_uuid])
  end

  private
  def use_course!
    @bundle = Courses::BundleCodingFrontEnd.instance
    @course = Courses::Course.course_for_slug(params[:id])
    redirect_to action: :coding_fundamentals unless @course
  end

  def use_enrollment!
    if session[:enrollment_id]
      begin
        @enrollment = CourseEnrollment.find(session[:enrollment_id])
        return
      rescue ActiveRecord::RecordNotFound
        session.delete(:enrollment_id)
      end
    end

    return unless user_signed_in? && @course

    @enrollment = CourseEnrollment.find_by(
      user: current_user,
      course_slug: @course.slug
    )
    session[:enrollment_id] = @enrollment.id if @enrollment
  end

  def use_location!
    @country_code_2 = @enrollment&.country_code_2.presence ||
                      session[:location_country_code].presence ||
                      retrieve_location_from_vpnapi!
  rescue StandardError
    # Rate limit probably
  end

  def retrieve_location_from_vpnapi!
    return session[:location_country_code] = "MX" unless Rails.env.production?

    data = JSON.parse(RestClient.get("https://vpnapi.io/api/#{request.remote_ip}?key=#{Exercism.secrets.vpnapi_key}").body)
    if data.dig("security", "vpn")
      @using_vpn = true
      return
    end

    session[:location_country_code] = data.dig("location", "country_code")
  end

  def setup_pricing!
    @course_full_price = @course.full_price
    @bundle_full_price = @bundle.full_price

    country_data = @course.pricing_data_for_country(@country_code_2)
    country_data ? setup_country_pricing!(country_data) : setup_default_pricing!
  end

  def setup_country_pricing!(country_data)
    @country_name = country_data[:country_name]
    @hello = country_data[:hello]

    @has_discount = true
    @bundle_price = country_data[:bundle_price].to_f
    @course_price = country_data[:course_price].to_f
    @discount_percentage = country_data[:discount_percentage]
  end

  def setup_default_pricing!
    @has_discount = false

    @bundle_price = @bundle.full_price
    @course_price = @course.full_price
  end

  # rubocop:disable Layout/LineLength
  def use_testimonials!
    @testimonials = [
      [
        "As someone with **no previous coding experience** - I've been blown away with the **quality of this course**. I've **come so far** in the past weeks and reflecting on what I've achieved and **how much I've learned has been phenomenal**. My journey has been from a complete coding novice, to someone who is **confident and excited to tackle complex logic problems** in code!",
        "Fred",
        "Total Beginner",
        "fred.png"
      ],
      [
        "I was brand new to coding and this course **exceeded my wildest expectations** and then some. In my humble opinion, it will be **one of the best choices you will ever make!**",
        "Shaun",
        "Absolute Beginner",
        "shaun.jpg"
      ],
      [
        "From the moment I bought the course, I realized it would **be different from anything I had ever experienced** in terms of classes and studying. Learning while actually coding **has made it pretty fun**.\n\nGetting help and encouraging messages from the community, sharing their experiences, and knowing that you're not alone made things much easier. It's **such a pleasure** to be part of it!",
        "Lucas",
        "Total Beginner",
        "lukas.webp"
      ],
      [
        "Getting into **programming always felt overwhelming**. I often quit before I really got started. However, the course has provided an **excellent, guided path to self-sufficiency**, and I now feel capable of growing and learning more in the field.",
        "Nolan Lounsbery",
        "Beginner",
        "giantlemur.jpg"
      ],
      [
        "This course has pushed me past what I thought were personal limitations, and in doing so, has **increased my confidence and motivation**. Know that when you get the certificate at the end of the course, it will be because you EARNED it!",
        "@RedRobio",
        "Junior Developer",
        "redrobio.jpg"
      ],
      [
        "Before this, I often relied on AI to solve coding problems. In fact, it was ChatGPT that recommended Exercism to me, and I instantly fell in love with it. So when I heard about Exercism Course, I didn’t think twice — I knew the **quality would be top-notch**. The **affordability was unbelievable**, and now, halfway through, I can proudly say **I’ve been almost three months ChatGPT-free! 🙂**",
        "Veronika",
        "Junior Developer",
        "veronika.jpg"
      ],
      [
        "The course provided me an opportunity to **learn from a bonafide master**. The purchasing power parity discount made it even more affordable. **Thank you for making it accessible**.",
        "@abhinav",
        "Beginner",
        "abhinav.png"
      ],
      [
        "Before I started this course I didn't think I could do the exercises we do now. **I thought I am not smart enough**, that “this is not for me” and I didn’t expect anything which required so much effort to be here in the fundamentals of programming. But in the end, **Jeremy shows it’s yet another skill that can be learnt**, even in such a **short period of time.**",
        "Oleksandra",
        "Beginner",
        "github.png"
      ],
      [
        "Very happy to have joined this course. Jeremy and the mentors are very **motivating, excellent tutors and highly skilled**. Great value in my opinion!",
        "Roger",
        "Beginner",
        "rogerb.webp"
      ],
      [
        "I'd recommend this to anyone trying to become a better programmer. I have done a fair bit of tutorial material online to learn programming but this course, does the best job In teaching you the fundamentals. This course has given me confidence in writing code and made it Fun! 😄 . The community, exercises , mentors, and Jeremy have all been to interact with. If you want, you can push(Course, you).",
        "Laura",
        "Was in Tutorial Hell",
        "laura.webp"
      ],
      [
        "I joined the course with some Python knowledge, looking to learn front-end languages. I’d been **struggling with self-paced learning**, so I signed up for the structure and accountability. The teaching style — **full of effective analogies** — really clicked with me.\n\nIn just 10 weeks, I’ve learned new material and **gained clarity on topics I thought I already understood**. Fantastic mentors, teaching, community, and global cohort. The course has exceeded my expectations—I’d highly recommend it!",
        "Matt",
        "Python Dev",
        "github.png"
      ],
      [
        "You will not believe how fantastic this course is! You learn to write code by writing code to solve problems that match--and push--your abilities. Jeremy is a master teacher. Exercism is the perfect environment. Mix in the camaraderie of people all over the world along with mentors ready at hand to help, and there is nothing like this bootcamp anywhere. It will do what everything else has failed to do. And it is the one you'll keep recommending to everyone you know.",
        "Thom Chittom",
        "Beginner",
        "thom.webp"
      ],

      [
        "I had doubts that I would understand this kind of material, and yet as I look back to where I started, I have a deep appreciation for the incredible skills and knowledge I am now nurturing and growing. **How I think about thinking, and about problem solving in general, has changed dramatically** since undertaking this course. I can't wait to see what's next!",
        "@Kazzybits",
        "Beginner",
        "kazzybits.webp"
      ],
      [
        "I joined this course with **some coding experience**, but the clarity and structure **made everything click like never before** and the lessons are perfectly paced, building concepts step-by-step in a way that **feels natural and engaging**. It's a transformative learning experience that **leaves you feeling motivated and excited** to keep pushing your coding skills to the next level.",
        "Vignesh",
        "Intermediate Dev",
        "vignesh.webp"
      ],
      [
        "Honestly, I had no expectations when I stumbled upon Exercism through a random ChatGPT search 😅, but it turned out to be **my greatest discovery of the year!** I was lucky to find it just as Part 1 of the Course was about to begin, and given the cost, I didn’t hesitate to join and give it a try.\n\nI had no experience whatsoever, and now that we’re almost done with Part 1, **I’m very impressed with myself** looking at what I can do! 100% recommended!",
        "Rick",
        "Beginner",
        "ricksn.jpg"
      ],
      [
        "This course hasn't just taught basic structures and logic for programming, but **it instills some basic tenets of the coder's mindset** that will be invaluable on your journey (**how to start from a blank screen**, breaking big impossible challenges into the smallest solvable pieces, creating more efficient, readable, and maintainable code).",
        "Robert",
        "Junior Developer",
        "rob.jpg"
      ],
      [
        "I have next to no coding experience yet have found this course to be **so intelligently scaffolded**, with **concepts clearly explained and logically built one after the other**, making the information accessible to learn.",
        "Karen",
        "Beginner",
        "github.png"
      ],
      [
        "This course gives you the **tools to think through the process** before even writing a single line of code which makes the actual coding part easier. Having **a good mental model** helps with understanding what's 'under the hood'",
        "@kcash",
        "Intermediate Dev",
        "kcash.webp"
      ],
      [
        "The **resources are fantastic** but it is Jeremy's knack of breaking things down into **the smallest possible steps** that has really helped things click for me.  I've **learned an unbelievable amount** in a few short weeks and I'm now **solving problems with code that I would never have thought possible!**",
        "Cpt Drac",
        "Total Beginner",
        "drac.webp"
      ],
      [
        "Jeremy and the mentors have created an amazing **resource like no other** on the web. From the **fun and sleek interface**, to the live classes and labs or the discord discussions, it all comes together to make **a superb learning experience**.",
        "@JJ",
        "Junior Developer",
        "jj.webp"
      ],
      [
        "Enrolling in this programming course was one of the **best decisions I’ve ever made**. The curriculum is well-structured, covering foundational programming concepts. The team behind this course is **supportive, and truly invested** in helping students succeed.",
        "@nanouss01",
        "Beginner",
        "nanouss01.webp"
      ],
      [
        "For nearly a decade, **I've repeatedly started online coding courses**, but every time I run up against something that didn't make sense or a problem I just couldn't solve which stopped me in my tracks, meaning I have never completed a course, but now after years of trying, suddenly, **coding feels possible.**",
        "Chris",
        "Serial beginner",
        "sharpiemath.png"
      ],
      [
        "I learned a bit of programming at university (I'm a mathematician), but the course has been **a game-changer for me**.\n\nThe pace is perfect: **challenging yet not impossible**. The exercises are very nice, and it is **incredibly satisfying** to see that in just a few weeks one can pass from simply moving a blob in a maze to program one that solve EVERY maze.\n\nThe classes and labs are very well planned: even when I've solved the exercises, I always learn something more from the labs. The analogies that Jeremy uses to teach us coding are powerful and **gave me a deeper knowledge even of things I knew.**",
        "@m_artigiani",
        "",
        "m_artigiani.webp"
      ],
      [
        "As a first-time course attendee, I was skeptical at first, since I was looking for a platform that was not just theory. Exercism has been **a game-changer** in that regard.\n\nThe weekly exercises have provided me with hands-on practice, helping me improve key programming concepts. The **visual representation, creating mental models, mentor feedback, and the interactive exercises** have been incredibly valuable.\n\nThanks to this course, **I feel more confident** and I’ve been able to shape my mindset and hoping to apply that to my personal and professional projects. If you’re looking for a way to reinforce your learning through hands-on coding, **I highly recommend it!**",
        "@nilophars",
        "",
        "nilophars.webp"
      ]
    ]
  end

  def use_quotes!
    @quotes = [
      [
        "As someone with **no previous coding experience** - I've been blown away with the **quality of this course**. I've **come so far** in the past weeks and reflecting on what I've achieved and **how much I've learned has been phenomenal**. My journey has been from a complete coding novice, to someone who is **confident and excited to tackle complex logic problems** in code!",
        "Fred",
        "Total Beginner",
        "fred.png"
      ],
      [
        "I was brand new to coding and this course **exceeded my wildest expectations** and then some. In my humble opinion, it will be **one of the best choices you will ever make!**",
        "Shaun",
        "Absolute Beginner",
        "shaun.jpg"
      ],
      [
        "From the moment I bought the course, I realized it would **be different from anything I had ever experienced** in terms of classes and studying. Learning while actually coding **has made it pretty fun**. Getting help and encouraging messages from the community, sharing their experiences, and knowing that you're not alone made things much easier. It's **such a pleasure** to be part of it!",
        "Lucas",
        "Total Beginner",
        "lukas.webp"
      ],
      [
        "Getting into **programming always felt overwhelming**. I often quit before I really got started. However, the course has provided an **excellent, guided path to self-sufficiency**, and I now feel capable of growing and learning more in the field.",
        "Nolan Lounsbery",
        "Beginner",
        "giantlemur.jpg"
      ],
      [
        "This course has pushed me past what I thought were personal limitations, and in doing so, has **increased my confidence and motivation**. Know that when you get the certificate at the end of the course, it will be because you EARNED it!",
        "@RedRobio",
        "Junior Developer",
        "redrobio.jpg"
      ],
      [
        "I joined the course with some Python knowledge, looking to learn front-end languages. I’d been **struggling with self-paced learning**, so I signed up for the structure and accountability. The teaching style — **full of effective analogies** — really clicked with me. In just 10 weeks, I’ve learned new material and **gained clarity on topics I thought I already understood**. Fantastic mentors, teaching, community, and global cohort. The course has exceeded my expectations—I’d highly recommend it!",
        "Matt",
        "Python Dev",
        "github.png"
      ],
      [
        "The course provided me an opportunity to **learn from a bonafide master**. The purchasing power parity discount made it even more affordable. **Thank you for making it accessible**.",
        "@abhinav",
        "Beginner",
        "abhinav.png"
      ],
      [
        "I'd recommend this to anyone trying to become a better programmer. I have done a fair bit of tutorial material online to learn programming but this course **does the best job in teaching you the fundamentals**. This course has **given me confidence in writing code and made it fun! 😄**.",
        "Laura",
        "Was in Tutorial Hell",
        "laura.webp"
      ],
      [
        "Before I started this course I didn't think I could do the exercises we do now. **I thought I am not smart enough**, that “this is not for me” and I didn’t expect anything which required so much effort to be here in the fundamentals of programming. But in the end, **Jeremy shows it’s yet another skill that can be learnt**, even in such a **short period of time.**",
        "Oleksandra",
        "Beginner",
        "github.png"

      ],
      [
        "I had doubts that I would understand this kind of material, and yet as I look back to where I started, I have a deep appreciation for the incredible skills and knowledge I am now nurturing and growing. **How I think about thinking, and about problem solving in general, has changed dramatically** since undertaking this course. I can't wait to see what's next!",
        "@Kazzybits",
        "Beginner",
        "kazzybits.webp"
      ],
      [
        "I joined this course with **some coding experience**, but the clarity and structure **made everything click like never before** and the lessons are perfectly paced, building concepts step-by-step in a way that **feels natural and engaging**. It's a transformative learning experience that **leaves you feeling motivated and excited** to keep pushing your coding skills to the next level.",
        "Vignesh",
        "Intermediate Dev",
        "vignesh.webp"
      ],
      [
        "Honestly, I had no expectations when I stumbled upon Exercism, but it turned out to be **my greatest discovery of the year!** Given the cost, I didn’t hesitate to join and give it a try. I had no experience whatsoever, and **I’m very impressed with myself** looking at what I can do! 100% recommended!",
        "Rick",
        "Beginner",
        "ricksn.jpg"
      ],
      [
        "The course has been **a game-changer for me**.The pace is perfect: **challenging yet not impossible**. The exercises are very nice, and it is **incredibly satisfying** to see that in just a few weeks one can pass from simply moving a blob in a maze to program one that solve EVERY maze.\n\n",
        "@m_artigiani",
        "",
        "m_artigiani.webp"
      ],
      [
        "This course hasn't just taught basic structures and logic for programming, but **it instills some basic tenets of the coder's mindset** that will be invaluable on your journey (**how to start from a blank screen**, breaking big impossible challenges into the smallest solvable pieces, creating more efficient, readable, and maintainable code).",
        "Robert",
        "Junior Developer",
        "rob.jpg"
      ],
      [
        "I have next to no coding experience yet have found this course to be **so intelligently scaffolded**, with **concepts clearly explained and logically built one after the other**, making the information accessible to learn.",
        "Karen",
        "Beginner",
        "github.png"
      ],
      [
        "This course gives you the **tools to think through the process** before even writing a single line of code which makes the actual coding part easier. Having **a good mental model** helps with understanding what's 'under the hood'",
        "@kcash",
        "Intermediate Dev",
        "kcash.webp"
      ],
      [
        "The **resources are fantastic** but it is Jeremy's knack of breaking things down into **the smallest possible steps** that has really helped things click for me.  I've **learned an unbelievable amount** in a few short weeks and I'm now **solving problems with code that I would never have thought possible!**",
        "Cpt Drac",
        "Total Beginner",
        "drac.webp"
      ],
      [
        "Jeremy and the mentors have created an amazing **resource like no other** on the web. From the **fun and sleek interface**, to the live classes and labs or the discord discussions, it all comes together to make **a superb learning experience**.",
        "@JJ",
        "Junior Developer",
        "jj.webp"
      ],
      [
        "Enrolling in this programming course was one of the **best decisions I’ve ever made**. The curriculum is well-structured, covering foundational programming concepts. The team is **supportive, and truly invested** in helping students succeed.",
        "@nanouss01",
        "Beginner",
        "nanouss01.webp"
      ],
      [
        "You will not believe **how fantastic this course is**! You learn to write code by writing code to solve problems that match--and push--your abilities. **Jeremy is a master teacher.** Exercism is the perfect environment.",
        "Thom Chittom",
        "Beginner",
        "thom.webp"
      ],
      [
        "For nearly a decade, **I've repeatedly started online coding courses**, but every time I run up against something that didn't make sense or a problem I just couldn't solve which stopped me in my tracks, meaning I have never completed a course, but now after years of trying, suddenly, **coding feels possible.**",
        "Chris",
        "Serial beginner",
        "sharpiemath.png"
      ]
    ]
  end
  # rubocop:enable Layout/LineLength
end
