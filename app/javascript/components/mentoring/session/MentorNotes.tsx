import React from 'react'
import { useHighlighting } from '../../../utils/highlight'

export const MentorNotes = ({ notes }: { notes?: string }): JSX.Element => {
  const ref = useHighlighting<HTMLDivElement>()

  if (notes) {
    return (
      <React.Fragment>
        <div
          className="c-textual-content --small"
          ref={ref}
          dangerouslySetInnerHTML={{ __html: notes }}
        />
        <p>CTA to improve notes here</p>
      </React.Fragment>
    )
  } else {
    return <p>CTA to contribute notes here</p>
  }
}
