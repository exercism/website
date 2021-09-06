import React from 'react'
import { GenericTooltip } from '../misc/ExercismTippy'

export const Pronouns = ({
  handle,
  pronouns,
}: {
  handle: string
  pronouns?: string[]
}): JSX.Element => {
  if (pronouns == null) {
    return <></>
  }

  const useHandle = handle.toLowerCase() == pronouns[0].toLowerCase()

  const content = useHandle ? (
    <>
      Rather than using pronouns (he, her's, etc) please always refer to{' '}
      {handle} as {handle}.
    </>
  ) : (
    <>
      <p>
        When refering to {handle}, please use the pronouns "
        {pronouns.join(' / ')}".
      </p>
      <p>For example, if leaving a testimonial for {handle}, you might say:</p>
      <blockquote>
        "{handle} was great. {pronouns[0]} answered all my questions. I'll
        recommend {pronouns[1]} to others because {pronouns[2]} advice was very
        helpful."
      </blockquote>
    </>
  )

  return (
    <GenericTooltip content={content} className="c-pronouns-tooltip">
      <div className="c-pronouns">
        {useHandle ? 'Do not use pronouns' : pronouns.join(' / ')}
      </div>
    </GenericTooltip>
  )
}
