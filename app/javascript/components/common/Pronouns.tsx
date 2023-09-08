import React, { useState } from 'react'
import { GenericTooltip } from '../misc/ExercismTippy'

export const Pronouns = ({
  handle,
  pronouns,
}: {
  handle: string
  pronouns?: string[]
}): JSX.Element | null => {
  const [pronounsWithFallback] = useState(
    pronouns?.map((p) => (p === '' ? handle : p))
  )
  if (!pronounsWithFallback || pronounsWithFallback.length === 0) return null

  const useHandle =
    handle.toLowerCase() !== pronounsWithFallback[0].toLowerCase()

  const content = useHandle
    ? createExample(handle, pronounsWithFallback)
    : `Rather than using pronouns (he, her's, etc) please always refer to ${handle} as ${handle}.`

  return (
    <GenericTooltip content={content} className="c-pronouns-tooltip">
      <div className="cursor-default">
        {useHandle ? pronounsWithFallback.join(' / ') : 'Do not use pronouns'}
      </div>
    </GenericTooltip>
  )
}

function createExample(handle: string, pronouns: string[]) {
  return (
    <>
      <p>
        {`When refering to ${handle}, please use the pronouns "${pronouns.join(
          ' / '
        )}".`}
      </p>
      <p>For example, if leaving a testimonial for {handle}, you might say:</p>
      <blockquote>{`"${handle} was great. ${pronouns[0]} answered all my questions. I'll recommend ${pronouns[1]} to others because ${pronouns[2]} advice was very helpful." ${pronouns[4]}`}</blockquote>
    </>
  )
}
