import { Credits } from '@/components/common'
import { useHighlighting } from '@/hooks'
import React, { useContext } from 'react'
import { Approach, DigDeeperDataContext } from '../DigDeeper'

export function ApproachSnippet({
  approach,
}: {
  approach: Approach
}): JSX.Element {
  const codeBlockRef = useHighlighting<HTMLPreElement>()

  const { track } = useContext(DigDeeperDataContext)

  return (
    <a
      href={approach.links.self}
      className="bg-white shadow-base rounded-8 px-20 py-16 mb-16"
    >
      <pre
        className="border-1 border-lightGray rounded-8 p-16 mb-16"
        ref={codeBlockRef}
      >
        <code
          className={`${track.slug} block max-h-[134px] overflow-hidden `}
          style={{ textOverflow: 'ellipsis' }}
        >
          {approach.snippet}
        </code>
      </pre>
      <h5 className="text-h5 mb-2">{approach.title}</h5>
      <p className="text-p-base text-textColor6 mb-12">{approach.blurb}</p>
      <Credits
        topLabel={'author'}
        topCount={approach.numAuthors}
        bottomLabel={'contributor'}
        bottomCount={approach.numContributors}
        avatarUrls={approach.users.map((i) => i.avatarUrl)}
      />
    </a>
  )
}
