import React from 'react'
import { GenericTooltip } from '../misc/ExercismTippy'
import GraphicalIcon from './GraphicalIcon'

export const Pronouns = ({
  handle,
  pronouns,
}: {
  handle: string
  pronouns?: string[]
}): JSX.Element | null => {
  if (!pronouns || pronouns.length === 0) return null

  const useHandle = handle.toLowerCase() !== pronouns[0].toLowerCase()

  const content = useHandle
    ? createExample(handle, pronouns)
    : `Rather than using pronouns (he, her's, etc) please always refer to ${handle} as ${handle}.`

  return (
    <GenericTooltip content={content} className="c-pronouns-tooltip">
      <div className="cursor-default text-textColor6 font-semibold flex items-center gap-8 mb-6">
        <GraphicalIcon
          icon="user"
          className="filter-textColor6"
          width={16}
          height={16}
        />
        {useHandle ? pronouns.join(' / ') : 'Do not use pronouns'}
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
      <blockquote>{`"${handle} was great. ${pronouns[0]} answered all my questions. I'll recommend ${pronouns[1]} to others because ${pronouns[2]} advice was very helpful."`}</blockquote>
    </>
  )
}
