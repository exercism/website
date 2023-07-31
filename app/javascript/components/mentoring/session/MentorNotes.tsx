import React from 'react'

export const MentorNotes = ({
  notes,
  improveUrl,
  guidanceType,
}: {
  notes?: string
  improveUrl: string
  guidanceType: 'track' | 'exercise' | 'representer'
}): JSX.Element => {
  const prLink = (
    <a href={improveUrl} target="_blank" rel="noreferrer">
      Pull Request on GitHub
    </a>
  )

  if (!notes) {
    return (
      <p className="text-p-base">
        This {guidanceType} doesn&apos;t have any mentoring notes yet. Mentoring
        notes are written by our community. Please help get them started for
        this exercise by sending a {prLink}.
      </p>
    )
  }

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
        sending a {prLink}.
      </p>
    </React.Fragment>
  )
}
