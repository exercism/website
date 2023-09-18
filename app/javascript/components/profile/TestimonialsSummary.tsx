import React, { useState } from 'react'
import {
  Avatar,
  GraphicalIcon,
  HandleWithFlair,
  ProminentLink,
} from '../common'
import { Testimonial } from '../types'
import { Flair } from '../common/HandleWithFlair'

type Props = {
  handle: string
  flair: Flair
  numTestimonials: number
  numSolutionsMentored: number
  numStudentsHelped: number
  numTestimonialsReceived: number
  testimonials: readonly Testimonial[]
  links: {
    all: string
  }
}
export default function TestimonialsSummary({
  handle,
  flair,
  numSolutionsMentored,
  numStudentsHelped,
  numTestimonialsReceived,
  testimonials,
  links,
}: Props): JSX.Element {
  const [currentTestimonial, setCurrentTestimonial] = useState(testimonials[0])

  return (
    <section className="testimonials-section">
      <div className="md-container container">
        <header className="section-header">
          <GraphicalIcon icon="testimonials" hex />
          <h2>Testimonials</h2>
          <hr className="c-divider" />
        </header>
        <div className="testimonials">
          <div className="stats">
            <div className="stat">
              <div className="number">
                {numSolutionsMentored.toLocaleString()}
              </div>
              <div className="metric">Solutions mentored</div>
            </div>
            <div className="stat">
              <div className="number">{numStudentsHelped.toLocaleString()}</div>
              <div className="metric">Students helped</div>
            </div>
            <div className="stat">
              <div className="number">
                {numTestimonialsReceived.toLocaleString()}
              </div>
              <div className="metric">Testimonials received</div>
            </div>
          </div>
          <div className="testimonial">{currentTestimonial.content}</div>
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
                testimonial === currentTestimonial ? 'active' : 'unactive',
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
                    <div className="student">
                      <HandleWithFlair
                        flair={testimonial.student.flair}
                        handle={testimonial.student.handle}
                      />
                    </div>
                    <div className="mentored-by">
                      Mentored by&nbsp;
                      <HandleWithFlair handle={handle} flair={flair} />
                    </div>
                    <div className="exercise">
                      <strong>{testimonial.exercise.title}</strong> in{' '}
                      <strong>{testimonial.track.title}</strong>
                    </div>
                  </div>
                </button>
              )
            })}
          </div>
        </div>
        {links.all ? (
          <ProminentLink
            link={links.all}
            text={`See all of ${handle}'s testimonials`}
          />
        ) : null}
      </div>
    </section>
  )
}
