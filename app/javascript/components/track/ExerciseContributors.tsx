import React, { useState } from 'react'
import pluralize from 'pluralize'
import { Avatar } from '../common'
import { User } from '../types'
import { ExerciseContributorsModal } from '../modals/ExerciseContributorsModal'

type Links = {
  contributors: string
}

export const ExerciseContributors = ({
  authors,
  numContributors,
  links,
}: {
  authors: readonly User[]
  numContributors: number
  links: Links
}): JSX.Element => {
  const [open, setOpen] = useState(false)

  return (
    <React.Fragment>
      <button type="button" className="makers" onClick={() => setOpen(!open)}>
        <div className="c-faces">
          {authors.map((author) => {
            return (
              <div className="face" key={author.handle}>
                <Avatar src={author.avatarUrl} handle={author.handle} />
              </div>
            )
          })}
        </div>
        <div className="stats">
          <div className="authors">
            {authors.length} {pluralize('author', authors.length)}
          </div>
          {numContributors > 0 ? (
            <div className="contributors">
              {numContributors} {pluralize('contributor', numContributors)}
            </div>
          ) : null}
        </div>
      </button>
      <ExerciseContributorsModal
        open={open}
        onClose={() => setOpen(false)}
        endpoint={links.contributors}
        className="m-exercise-contributors"
      />
    </React.Fragment>
  )
}
