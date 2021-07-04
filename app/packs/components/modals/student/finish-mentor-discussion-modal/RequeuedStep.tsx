import React from 'react'

type Links = {
  exercise: string
}

export const RequeuedStep = ({ links }: { links: Links }): JSX.Element => {
  return (
    <section className="acceptable-final-step">
      <h2>Your solution has been requeued.</h2>
      <p className="explanation">
        Your solution has been put back in the queue and another mentor will
        hopefully pick it up soon. We hope you have a positive mentoring session
        on this solution next time!
      </p>

      <div className="form-buttons">
        <a href={links.exercise} className="btn-primary btn-m">
          Go back to your solution
        </a>
      </div>
    </section>
  )
}
