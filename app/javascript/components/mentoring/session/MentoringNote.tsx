import React from 'react'

type Links = {
  mentoringDocs: string
}

export const MentoringNote = ({ links }: { links: Links }): JSX.Element => {
  return (
    <div className="note">
      Check out our{' '}
      <a href={links.mentoringDocs} target="_blank" rel="noreferrer">
        mentoring docs
      </a>{' '}
      for more information.
    </div>
  )
}
