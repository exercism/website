import React, { useState } from 'react'
import { Avatar, GraphicalIcon, ProminentLink } from '../common'

type Props = {
  handle: string
  numTestimonials: number
  numSolutionsMentored: number
  numStudentsHelped: number
  numTestimonialsReceived: number
  testimonials: readonly Testimonial[]
  links: {
    all: string
  }
}

export type Testimonial = {
  text: string
  student: {
    avatarUrl: string
    handle: string
  }
  exerciseTitle: string
  trackTitle: string
}

export const TestimonialSection = ({
  handle,
  numTestimonials,
  numSolutionsMentored,
  numStudentsHelped,
  numTestimonialsReceived,
  testimonials,
  links,
}: Props): JSX.Element => {
  const [currentTestimonial, setCurrentTestimonial] = useState(testimonials[0])

  return (
    <section className="testimonials-section">
      <div className="md-container container">
        <header className="section-header">
          <GraphicalIcon icon="testimonials" hex />
          <h2>Testimonials</h2>
          <div className="total-count">{numTestimonials}</div>
          <hr className="c-divider" />
        </header>
        <div className="testimonials">
          <div className="stats">
            <div className="stat">
              <div className="number">{numSolutionsMentored}</div>
              <div className="metric">Solutions mentored</div>
            </div>
            <div className="stat">
              <div className="number">{numStudentsHelped}</div>
              <div className="metric">Students helped</div>
            </div>
            <div className="stat">
              <div className="number">{numTestimonialsReceived}</div>
              <div className="metric">Testimonials received</div>
            </div>
          </div>
          <div className="testimonial">{currentTestimonial.text}</div>
          <div className="stars">
            <GraphicalIcon icon="gold-star" />
            <GraphicalIcon icon="gold-star" />
            <GraphicalIcon icon="gold-star" />
            <GraphicalIcon icon="gold-star" />
            <GraphicalIcon icon="gold-star" />
            <GraphicalIcon icon="gold-star" />
          </div>
          <div className="bylines">
            {testimonials.map((testimonial, i) => {
              const classNames = [
                'byline',
                testimonial === currentTestimonial ? 'active' : '',
              ].filter((className) => className.length > 0)

              return (
                <button
                  type="button"
                  onClick={() => setCurrentTestimonial(testimonials[i])}
                  className={classNames.join(' ')}
                  key={i}
                >
                  <Avatar
                    src={testimonial.student.avatarUrl}
                    handle={testimonial.student.handle}
                  />
                  <div className="info">
                    <div className="student">{testimonial.student.handle}</div>
                    <div className="exercise">
                      {testimonial.exerciseTitle} in {testimonial.trackTitle}
                    </div>
                  </div>
                </button>
              )
            })}
          </div>
        </div>
        <ProminentLink
          link={links.all}
          text={`See all of ${handle}'s testimonials`}
        />
      </div>
    </section>
  )
}
