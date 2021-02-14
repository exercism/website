import React from 'react'

export const MentorNotes = ({ notes }: { notes?: string }): JSX.Element => {
  if (notes) {
    return (
      <React.Fragment>
        <div
          className="c-textual-content --small"
          dangerouslySetInnerHTML={{ __html: notes }}
        />
        <p>CTA to improve notes here</p>
      </React.Fragment>
    )
  } else {
    return <p>CTA to contribute notes here</p>
  }
}
