import React from 'react'
import { GraphicalIcon, Icon } from '../../common'

export type Links = {
  video: string
  dashboard: string
}

export const CongratulationsStep = ({
  links,
}: {
  links: Links
}): JSX.Element => {
  return (
    <section className="celebrate-section">
      <GraphicalIcon icon="confetti" category="graphics" />
      <h2>You’re now a mentor!</h2>
      <h3>Thank you - we’re so grateful for your commitment 🙏</h3>
      <p className="welcome">
        We want to make getting started with mentoring as easy as possible.
        Watch the video below to learn how to get started.
      </p>
      <div className="video-frame">
        <header className="video-header">
          <Icon icon="video" alt="This is a video" />
          <div className="info">
            <h3>Welcome to the Mentor Team!</h3>
            <p>Video · 0:24</p>
          </div>
        </header>
        <div
          className="video"
          style={{ padding: '56.25% 0 0 0', position: 'relative' }}
        >
          <iframe
            src={links.video}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: '100%',
            }}
            frameBorder="0"
            allow="autoplay; fullscreen; picture-in-picture"
            allowFullScreen
          ></iframe>
        </div>
        <script src="https://player.vimeo.com/api/player.js"></script>
      </div>
      <a href={links.dashboard} className="btn-primary btn-m">
        I&apos;m ready to get started!
      </a>
    </section>
  )
}
