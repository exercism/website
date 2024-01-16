import React, { useState } from 'react'
import pluralize from 'pluralize'
import { Avatar } from '../common'
import { ExerciseMakersModal } from '../modals/ExerciseMakersModal'

type Links = {
  makers: string
}

export function ExerciseMakersButton({
  avatarUrls,
  numAuthors,
  numContributors,
  links,
}: {
  avatarUrls: readonly string[]
  numAuthors: number
  numContributors: number
  links: Links
}): JSX.Element {
  const [open, setOpen] = useState(false)

  return (
    <React.Fragment>
      <button
        type="button"
        className="c-makers-button"
        onClick={() => setOpen(!open)}
      >
        <div className="c-faces">
          {avatarUrls.map((avatarUrl, i) => (
            <Avatar className="face" src={avatarUrl} key={i} />
          ))}
        </div>
        <div className="stats">
          {numAuthors > 0 ? (
            <div className="authors">
              {numAuthors} {pluralize('author', numAuthors)}
            </div>
          ) : null}
          {numContributors > 0 ? (
            <div className="contributors">
              {numContributors} {pluralize('contributor', numContributors)}
            </div>
          ) : null}
        </div>
      </button>
      <ExerciseMakersModal
        open={open}
        onClose={() => setOpen(false)}
        endpoint={links.makers}
      />
    </React.Fragment>
  )
}
export default ExerciseMakersButton
