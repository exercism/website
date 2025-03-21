class CoursesController < ApplicationController
  layout 'courses'
  skip_before_action :authenticate_user!

  # before_action :redirect_if_paid!
  before_action :use_course!, only: %i[show start_enrolling enroll pay]
  before_action :use_enrollment!
  before_action :use_location!, only: %i[show start_enrolling enroll pay]
  before_action :setup_pricing!, only: %i[show start_enrolling enroll pay]
  before_action :use_quotes!, only: [:show]

  def use_course!
    @bundle = Courses::BundleCodingFrontEnd.instance
    @course = Courses::Course.course_for_slug(params[:id])
    redirect_to action: :index unless @course
  end

  def use_enrollment!
    if session[:enrollment_id]
      @enrollment = CourseEnrollment.find(session[:enrollment_id])
    elsif user_signed_in?
      @enrollment = CourseEnrollment.find_by(
        user: current_user,
        course_slug: @course.slug
      )
      session[:enrollment_id] = @enrollment.id if @enrollment
    end
  rescue StandardError
  end

  def show
    render action: @course.template_slug
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
      return_url: "#{courses_enrolled_url}?failure_path=#{course_pay_path(@enrollment.course_slug)}&session_id={CHECKOUT_SESSION_ID}"
    })

    render json: { clientSecret: session.client_secret }
  end

  def stripe_session_status
    session = Stripe::Checkout::Session.retrieve(params[:session_id])

    if session.status == 'complete'
      @enrollment.update!(checkout_session_id: session.id)
      @enrollment.paid!(session.id)
    end

    render json: {
      status: session.status,
      customer_email: session.customer_details.email
    }
  end

  def enrolled; end

  private
  def use_location!
    @country_code_2 = @enrollment&.country_code_2.presence ||
                      session[:location_country_code].presence ||
                      retrieve_location_from_vpnapi!
  rescue StandardError
    # Rate limit probably
  end

  def retrieve_location_from_vpnapi!
    return session[:location_country_code] = "IN" unless Rails.env.production?

    data = JSON.parse(RestClient.get("https://vpnapi.io/api/#{request.remote_ip}?key=#{Exercism.secrets.vpnapi_key}").body)
    return if data.dig("security", "vpn")

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
    @bundle_payment_url = country_data[:bundle_payment_url]
    @course_payment_url = country_data[:course_payment_url]
    @discount_percentage = country_data[:discount_percentage]
  end

  def setup_default_pricing!
    @has_discount = false

    @bundle_price = @bundle.full_price
    @bundle_payment_url = @bundle.default_payment_url

    @course_price = @course.full_price
    @course_payment_url = @course.default_payment_url
  end

  def use_testimonials!
    @testimonials = [
      [
        "As someone with **no previous coding experience** - I've been blown away with the **quality of this course**. I've **come so far** in the past weeks and reflecting on what I've achieved and **how much I've learned has been phenomenal**. My journey has been from a complete coding novice, to someone who is **confident and excited to tackle complex logic problems** in code!",
        "Fred",
        "Total Beginner",
        "fred.png"
      ],
      [
        "I was brand new to coding and this bootcamp **exceeded my wildest expectations** and then some. In my humble opinion, it will be **one of the best choices you will ever make!**",
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
        "Getting into **programming always felt overwhelming**. I often quit before I really got started. However, the bootcamp has provided an **excellent, guided path to self-sufficiency**, and I now feel capable of growing and learning more in the field.",
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
        "Before this, I often relied on AI to solve coding problems. In fact, it was ChatGPT that recommended Exercism to me, and I instantly fell in love with it. So when I heard about Exercism Bootcamp, I didn’t think twice — I knew the **quality would be top-notch**. The **affordability was unbelievable**, and now, halfway through, I can proudly say **I’ve been almost three months ChatGPT-free! 🙂**",
        "Veronika",
        "Junior Developer",
        "veronika.jpg"
      ],
      [
        "The bootcamp provided me an opportunity to **learn from a bonafide master**. The purchasing power parity discount made it even more affordable. **Thank you for making it accessible**.",
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
        "Honestly, I had no expectations when I stumbled upon Exercism through a random ChatGPT search 😅, but it turned out to be **my greatest discovery of the year!** I was lucky to find it just as Part 1 of the Bootcamp was about to begin, and given the cost, I didn’t hesitate to join and give it a try. I had no experience whatsoever, and now that we’re almost done with Part 1, **I’m very impressed with myself** looking at what I can do! 100% recommended!",
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
        "Enrolling in this programming bootcamp was one of the **best decisions I’ve ever made**. The curriculum is well-structured, covering foundational programming concepts. The team behing this bootcamp is **supportive, and truly invested** in helping students succeed.",
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
        "I learned a bit of programming at university (I'm a mathematician), but the bootcamp has been **a game-changer for me**.\n\nThe pace is perfect: **challenging yet not impossible**. The exercises are very nice, and it is **incredibly satisfying** to see that in just a few weeks one can pass from simply moving a blob in a maze to program one that solve EVERY maze.\n\nThe classes and labs are very well planned: even when I've solved the exercises, I always learn something more from the labs. The analogies that Jeremy uses to teach us coding are powerful and **gave me a deeper knowledge even of things I knew.**",
        "@m_artigiani",
        "",
        "m_artigiani.webp"
      ],
      [
        "As a first-time bootcamp attendee, I was skeptical at first, since I was looking for a platform that was not just theory. Exercism has been **a game-changer** in that regard.\n\nThe weekly exercises have provided me with hands-on practice, helping me improve key programming concepts. The **visual representation, creating mental models, mentor feedback, and the interactive exercises** have been incredibly valuable.\n\nThanks to this bootcamp, **I feel more confident** and I’ve been able to shape my mindset and hoping to apply that to my personal and professional projects. If you’re looking for a way to reinforce your learning through hands-on coding, **I highly recommend it!**",
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
        "I was brand new to coding and this bootcamp **exceeded my wildest expectations** and then some. In my humble opinion, it will be **one of the best choices you will ever make!**",
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
        "Getting into **programming always felt overwhelming**. I often quit before I really got started. However, the bootcamp has provided an **excellent, guided path to self-sufficiency**, and I now feel capable of growing and learning more in the field.",
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
        "Before this, I often relied on AI to solve coding problems. In fact, it was ChatGPT that recommended Exercism to me, and I instantly fell in love with it. So when I heard about Exercism Bootcamp, I didn’t think twice — I knew the **quality would be top-notch**. The **affordability was unbelievable**, and now, halfway through, I can proudly say **I’ve been almost three months ChatGPT-free! 🙂**",
        "Veronika",
        "Junior Developer",
        "veronika.jpg"
      ],
      [
        "The bootcamp provided me an opportunity to **learn from a bonafide master**. The purchasing power parity discount made it even more affordable. **Thank you for making it accessible**.",
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
        "Honestly, I had no expectations when I stumbled upon Exercism through a random ChatGPT search 😅, but it turned out to be **my greatest discovery of the year!** I was lucky to find it just as Part 1 of the Bootcamp was about to begin, and given the cost, I didn’t hesitate to join and give it a try. I had no experience whatsoever, and now that we’re almost done with Part 1, **I’m very impressed with myself** looking at what I can do! 100% recommended!",
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
        "Enrolling in this programming bootcamp was one of the **best decisions I’ve ever made**. The curriculum is well-structured, covering foundational programming concepts. The team behing this bootcamp is **supportive, and truly invested** in helping students succeed.",
        "@nanouss01",
        "Beginner",
        "nanouss01.webp"
      ],
      [
        "For nearly a decade, **I've repeatedly started online coding courses**, but every time I run up against something that didn't make sense or a problem I just couldn't solve which stopped me in my tracks, meaning I have never completed a course, but now after years of trying, suddenly, **coding feels possible.**",
        "Chris",
        "Serial beginner",
        "sharpiemath.png"
      ]
    ]
  end

  #   before_action :redirect_if_paid!
  #   before_action :save_utm!
  #   before_action :setup_data!
  #   before_action :setup_pricing!
  #
  #   def ltc
  #     if @bootcamp_data
  #       @bootcamp_data.num_views += 1
  #       @bootcamp_data.last_viewed_at = Time.current
  #       @bootcamp_data.ppp_country = @country_code_2 if @country_code_2
  #       @bootcamp_data.save
  #     end
  #   end
  #
  #   def bootcamp
  #     if @bootcamp_data
  #       @bootcamp_data.num_views += 1
  #       @bootcamp_data.last_viewed_at = Time.current
  #       @bootcamp_data.ppp_country = @country_code_2 if @country_code_2
  #       @bootcamp_data.save
  #     end
  #
  #     difference_in_seconds = Time.utc(2025, 1, 11, 18, 0, 0) - Time.current
  #
  #     # Convert to days, hours, minutes, and seconds
  #     @days = (difference_in_seconds / (24 * 60 * 60)).to_i
  #     @hours = (difference_in_seconds % (24 * 60 * 60) / (60 * 60)).to_i
  #     @minutes = (difference_in_seconds % (60 * 60) / 60).to_i
  #     @seconds = (difference_in_seconds % 60).to_i
  #   end
  #
  #   def start_enrolling
  #     create_bootcamp_data!
  #
  #     @name = @bootcamp_data.name || @bootcamp_data&.user&.name
  #     @email = @bootcamp_data.email || @bootcamp_data&.user&.email
  #     @package = params[:package] || @bootcamp_data.package
  #
  #     unless @bootcamp_data.enrolled?
  #       @bootcamp_data.started_enrolling_at = Time.current
  #       @bootcamp_data.package = @package if params[:package].present?
  #       @bootcamp_data.save!
  #     end
  #   end
  #
  #   def do_enrollment
  #     create_bootcamp_data!
  #
  #     @bootcamp_data.update!(
  #       enrolled_at: Time.current,
  #       name: params[:name],
  #       email: params[:email],
  #       package: params[:package],
  #       ppp_country: @country_code_2
  #     )
  #
  #     redirect_to action: :pay
  #   end
  #
  #   def pay
  #     redirect_to action: :start_enrolling unless @bootcamp_data&.enrolled?
  #   end
  #
  #   def stripe_create_checkout_session
  #     if Rails.env.production?
  #       stripe_price = @bootcamp_data.stripe_price_id
  #     else
  #       stripe_price = "price_1QCjUFEoOT0Jqx0UJOkhigru"
  #     end
  #
  #     session = Stripe::Checkout::Session.create({
  #       ui_mode: 'embedded',
  #       customer_email: @bootcamp_data.email,
  #       customer_creation: "always",
  #       line_items: [{
  #         price: stripe_price,
  #         quantity: 1
  #       }],
  #       mode: 'payment',
  #       allow_promotion_codes: true,
  #       return_url: "#{bootcamp_confirmed_url}?session_id={CHECKOUT_SESSION_ID}"
  #     })
  #
  #     render json: { clientSecret: session.client_secret }
  #   end
  #
  #   def stripe_session_status
  #     session = Stripe::Checkout::Session.retrieve(params[:session_id])
  #
  #     if session.status == 'complete'
  #       @bootcamp_data.update!(
  #         paid_at: Time.current,
  #         checkout_session_id: session.id,
  #         access_code: SecureRandom.hex(8)
  #       )
  #       if current_user
  #         User::BecomeBootcampAttendee.(current_user)
  #       else
  #         user = User.find_by(email: @bootcamp_data.email)
  #         if user
  #           # Reset old bootcamp data sessions
  #           User::BootcampData.where(user:).
  #             where.not(id: @bootcamp_data.id).
  #             update_all(user_id: nil)
  #
  #           # Enroll this one.
  #           @bootcamp_data.update(user:)
  #           User::BecomeBootcampAttendee.(user)
  #         end
  #       end
  #     end
  #
  #     render json: {
  #       status: session.status,
  #       customer_email: session.customer_details.email
  #     }
  #   end
  #
  #   def confirmed; end
  #
  #   private
  #   def setup_data!
  #     @bootcamp_data = retrieve_user_bootcamp_data_from_user
  #     @bootcamp_data ||= retrieve_user_bootcamp_data_from_session
  #
  #     if @bootcamp_data && @bootcamp_data.ppp_country.present?
  #       session[:bootcamp_data_id] = @bootcamp_data.id
  #       @country_code_2 = @bootcamp_data.ppp_country
  #     elsif session[:country_code_2].present?
  #       @country_code_2 = session[:country_code_2]
  #     else
  #       @country_code_2 = lookup_country_code_from_ip
  #       session[:country_code_2] = @country_code_2
  #     end
  #
  #
  #     if @bootcamp_data && @bootcamp_data.user_id&.nil? && cookies.signed[:_exercism_user_id].present?
  #       @bootcamp_data.update(user_id: cookies.signed[:_exercism_user_id])
  #     end
  #       #   end
  #
  #   def retrieve_user_bootcamp_data_from_user
  #     user_id = cookies.signed[:_exercism_user_id]
  #     return unless user_id
  #
  #     user = User.find_by(id: user_id)
  #     return unless user
  #
  #     begin
  #       user.bootcamp_data || user.create_bootcamp_data!
  #     rescue ActiveRecord::RecordNotUnique
  #       # Guard the race condition
  #       user.bootcamp_data
  #     end
  #   rescue StandardError
  #     # Something's a mess, but don't blow up.
  #   end
  #
  #   def retrieve_user_bootcamp_data_from_session
  #     return unless session[:bootcamp_data_id].present?
  #
  #     User::BootcampData.find(session[:bootcamp_data_id])
  #   rescue StandardError
  #     # We don't have anything valid in the session.
  #   end
  #
  #   def lookup_country_code_from_ip
  #     return "MX" unless Rails.env.production?
  #
  #     data = JSON.parse(RestClient.get("https://vpnapi.io/api/#{request.remote_ip}?key=#{Exercism.secrets.vpnapi_key}").body)
  #     return "VPN" if data.dig("security", "vpn")
  #
  #     data.dig("location", "country_code")
  #   rescue StandardError
  #     # Rate limit probably
  #   end
  #
  #   def create_bootcamp_data!
  #     return if @bootcamp_data
  #
  #     @bootcamp_data = User::BootcampData.create!(ppp_country: @country_code_2, utm: session[:utm])
  #     session[:bootcamp_data_id] = @bootcamp_data.id
  #
  #     return unless cookies.signed[:_exercism_user_id].present? && @bootcamp_data.user_id.nil?
  #
  #     @bootcamp_data.update(user_id: cookies.signed[:_exercism_user_id])
  #   end
  #
  #   def setup_pricing!
  #     country_data = User::BootcampData::DATA[@country_code_2]
  #     if country_data
  #       @country_name = country_data[0]
  #       @hello = country_data[1]
  #
  #       @has_discount = true
  #       @price = country_data[2].to_f
  #       @part_1_price = country_data[3].to_f
  #       @full_payment_url = country_data[4]
  #       @part_1_payment_url = country_data[5]
  #
  #       @discount_percentage = (
  #         (
  #           User::BootcampData::PRICE - @price
  #         ) / User::BootcampData::PRICE * 100
  #       ).round
  #     else
  #       @has_discount = false
  #       @price = User::BootcampData::PRICE
  #       @part_1_price = User::BootcampData::PART_1_PRICE
  #       @full_payment_url = User::BootcampData::FULL_PAYMENT_URL
  #       @part_1_payment_url = User::BootcampData::PART_1_PAYMENT_URL
  #     end
  #
  #     @full_price = User::BootcampData::PRICE
  #     @full_part_1_price = User::BootcampData::PART_1_PRICE
  #   end
  #
  #   def save_utm!
  #     session[:utm] ||= {}
  #     session[:utm][:source] = params[:utm_source] if params[:utm_source].present?
  #     session[:utm][:medium] = params[:utm_medium] if params[:utm_medium].present?
  #     session[:utm][:campaign] = params[:utm_campaign] if params[:utm_campaign].present?
  #   end
  #
  #   def redirect_if_paid!
  #     return unless current_user&.bootcamp_attendee? || current_user&.bootcamp_mentor?
  #
  #     redirect_to bootcamp_dashboard_url
  #   end
  #
end
