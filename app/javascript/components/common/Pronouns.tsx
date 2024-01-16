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
    <GenericTooltip
      content={content}
      className="text-15 leading-140 !max-w-[420px]"
    >
      <div className="w-fit cursor-default text-textColor6 font-semibold flex items-center gap-8 mb-6">
        <GraphicalIcon
          icon="pronouns"
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
  const pronounsString = pronouns.join(' / ')
  return (
    <>
      <p>
        When refering to @{handle}, please use the pronouns{' '}
        <strong className="whitespace-nowrap">{pronounsString}</strong>. For
        example, if leaving a testimonial for {handle}, you might say:
      </p>
      <blockquote className="block border-l-3 border-borderColor6 mt-8 pl-8 italic">
        {`"${handle} was great. ${pronouns[0]} answered all my questions. I'll recommend ${pronouns[1]} to others because ${pronouns[2]} advice was very helpful."`}
      </blockquote>
    </>
  )
}
