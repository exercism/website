import React from 'react'

export const SolutionCommentTextArea = React.forwardRef<
  HTMLTextAreaElement,
  unknown
>((_, ref) => (
  <div className="question">
    <label htmlFor="request-mentoring-form-solution-comment">
      How can a mentor help you with this solution?
    </label>
    <p id="request-mentoring-form-solution-description">
      Give your mentor a starting point for the conversation. This will be your
      first comment during the session. Markdown is permitted.
    </p>
    <textarea
      ref={ref}
      id="request-mentoring-form-solution-comment"
      required
      minLength={20}
      aria-describedby="request-mentoring-form-solution-description"
    />
  </div>
))
