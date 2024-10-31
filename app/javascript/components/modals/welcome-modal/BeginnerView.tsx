import React from 'react'

export function JuniorView() {
  return (
    <>
      <div className="lhs">
        <header>
          <h1>Oooh, good timing! 👏</h1>

          <p className="mb-8">
            You've signed up at a great time! In January, we're running a
            one-off{' '}
            <strong className="font-semibold text-softEmphasis">
              part-time, remote bootcamp for beginners!
            </strong>
          </p>
          <p className="mb-8">
            We're going to teach you all the fundamentals with a hands-on
            project-based approach. No stuffy videos, no heavy theory, just lots
            of fun coding!
          </p>
          <p className="mb-8">
            It's super affordable, with discounts if you're a student,
            unemployed, or live in a country with an emerging economy.
          </p>
          <p className="mb-20">Watch our intro video to learn more 👉</p>
        </header>
        <div className="flex gap-8">
          <button type="button" className="btn-primary btn-l">
            Go to the Bootcamp ✨
          </button>

          <button className="btn-secondary btn-l" type="button">
            Skip &amp; Continue
          </button>
        </div>
      </div>
      <div className="rhs pt-72">
        <div
          className="video relative rounded-8 overflow-hidden !mb-24"
          style={{ padding: '56.25% 0 0 0', position: 'relative' }}
        >
          <iframe
            src="https://www.youtube-nocookie.com/embed/8rmbTWAncb8"
            title="Introducing the 'Community' tab"
            frameBorder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
          />
        </div>
        <div className="bubbles">
          <div className="bubble">
            {/* Fix */}
            <img src="/assets/bootcamp/wave-44e5a9c881849138d0810b3c78be16a4e14f7b7a.svg" />
            <div className="text">
              <strong>Live</strong> teaching
            </div>
          </div>
          <div className="bubble">
            {/* Fix */}
            <img src="/assets/bootcamp/fun-59abfe9a4e8628bbc7c86267225fafc2ccd2522a.svg" />
            <div className="text">
              <strong>Fun</strong> projects
            </div>
          </div>
          <div className="bubble">
            {/* Change to price.svg */}
            <img src="/assets/bootcamp/fun-59abfe9a4e8628bbc7c86267225fafc2ccd2522a.svg" />
            <div className="text">
              {' '}
              Priced <strong>fairly</strong>{' '}
            </div>
          </div>
        </div>
      </div>
    </>
  )
}
