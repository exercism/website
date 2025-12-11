class JikiController < ApplicationController
  layout 'courses'
  skip_before_action :authenticate_user!
  before_action :use_quotes!
  before_action :use_testimonials!

  def index
    @locale_options = Localization::TranslatorsController::LOCALE_OPTIONS.map do |flag, word, locale|
      ["#{flag} #{word}", locale]
    end
    @programming_language_options = JikiSignup::PROGRAMMING_LANGUAGES

    return unless user_signed_in?

    @existing_signup = JikiSignup.find_by(user: current_user)
  end

  def create
    unless user_signed_in?
      redirect_to jiki_path
      return
    end

    @existing_signup = JikiSignup::Create.(
      current_user,
      params[:preferred_locale],
      params[:preferred_programming_language]
    )

    respond_to do |format|
      format.html { redirect_to jiki_path }
      format.json { render json: { success: true, signup: @existing_signup } }
    end
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
