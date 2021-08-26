import React from 'react'

export const MentorNotes = ({
  notes,
  improveUrl,
}: {
  notes?: string
  improveUrl: string
}): JSX.Element => {
  if (notes) {
    return (
      <React.Fragment>
        <div
          className="c-textual-content --small"
          dangerouslySetInnerHTML={{ __html: notes }}
        />
        <hr className="c-divider --small my-16" />
        <h3 className="text-h5 mb-4">Improve these notes</h3>
        <p className="text-p-base">
          These notes are written by our community. Please help improve them by
          sending a <a href={improveUrl}>Pull Request on GitHub</a>.
        </p>
      </React.Fragment>
    )
  } else {
    return (
      <p className="text-p-base">
        This exercise doesn't have any mentoring notes yet. Mentoring notes are
        written by our community. Please help get them started for this exercise
        by sending a <a href={improveUrl}>Pull Request on GitHub</a>.
      </p>
    )
  }
}
