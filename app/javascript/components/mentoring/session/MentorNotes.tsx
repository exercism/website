import React from 'react'
import { useHighlighting } from '../../../utils/highlight'

export const MentorNotes = ({
  notes,
  improveUrl,
}: {
  notes?: string
  improveUrl: string
}): JSX.Element => {
  const ref = useHighlighting<HTMLDivElement>()

  if (notes) {
    return (
      <React.Fragment>
        <div
          className="c-textual-content --small"
          ref={ref}
          dangerouslySetInnerHTML={{ __html: notes }}
        />
        <hr className="c-divider --small my-16" />
        <h3 className="text-h5 mb-4">Improve these notes</h3>
        <p className="text-p-base">
          These notes are written by our community. Please help improve them by
          sending a{' '}
          <a href={improveUrl} target="_blank" rel="noreferrer">
            Pull Request on GitHub
          </a>
          .
        </p>
      </React.Fragment>
    )
  } else {
    return (
      <p className="text-p-base">
        This exercise doesn&apos;t have any mentoring notes yet. Mentoring notes
        are written by our community. Please help get them started for this
        exercise by sending a{' '}
        <a href={improveUrl} target="_blank" rel="noreferrer">
          Pull Request on GitHub
        </a>
        .
      </p>
    )
  }
}
