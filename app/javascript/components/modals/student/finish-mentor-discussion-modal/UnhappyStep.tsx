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
      {report.report ? (
        <React.Fragment>
          <h2>Thank you for your report</h2>
          <p className="explanation">
            Thanks for letting us know. We will look into your report and get
            back to you in the next few days. In the meantime we hope you have a
            better next experience.
          </p>
        </React.Fragment>
      ) : report.requeue ? (
        <React.Fragment>
          <h2>Your solution has been be requeued</h2>
          <p className="explanation">
            Your solution has been put back in the queue and another mentor will
            hopefully pick it up soon. We hope you have a positive mentoring
            session on this solution next time!
          </p>
        </React.Fragment>
      ) : (
        <React.Fragment>
          <h2>We hope you have a better next experience</h2>
          <p className="explanation">
            Sorry this experience wasn't great. We hope the next one will be
            better.
          </p>
        </React.Fragment>
      )}

      <div className="form-buttons">
        <a href={links.exercise} className="btn-primary btn-m">
          Go back to your solution
        </a>
      </div>
    </section>
  )
}
