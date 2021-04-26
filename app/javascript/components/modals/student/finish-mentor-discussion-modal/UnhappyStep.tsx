import React from 'react'
import { MentorReport } from '../FinishMentorDiscussionModal'

type Links = {
  exercise: string
}

export const UnhappyStep = ({
  report,
  links,
}: {
  report: MentorReport
  links: Links
}): JSX.Element => {
  return (
    <section className="unhappy-final-step">
      <div className="container">
        <div className="lhs">
          {report.report ? (
            <React.Fragment>
              <h2>Thank you for your report</h2>
              <p className="explanation">
                We will look into your report and get back to you in the next
                few days. In the meantime we hope you have a better next
                experience.
              </p>
            </React.Fragment>
          ) : report.requeue ? (
            <React.Fragment>
              <h2>Your solution will be requeued</h2>
              <p className="explanation">
                Your solution will be put back in the queue, and hopefully
                you'll have a positive mentoring session on this solution soon.
              </p>
            </React.Fragment>
          ) : (
            <React.Fragment>
              <h2>We hope you have a better next experience</h2>
              <p className="explanation">
                Sorry this experience wasn't great. Hopefully the next one will
                be better!
              </p>
            </React.Fragment>
          )}
        </div>
      </div>

      <div className="form-buttons">
        <a href={links.exercise} className="btn-cta">
          View your solution
        </a>
      </div>
    </section>
  )
}
