import React, { useContext } from 'react'
import Credits from '@/components/common/Credits'
import { useHighlighting } from '@/hooks/use-syntax-highlighting'
import { Approach, DigDeeperDataContext } from '../DigDeeper'

export function ApproachSnippet({
  approach,
}: {
  approach: Approach
}): JSX.Element {
  const codeBlockRef = useHighlighting<HTMLPreElement>(approach.snippet)

  const { track } = useContext(DigDeeperDataContext)

  return (
    <a
      href={approach.links.self}
      className="dig-deeper-snippet bg-backgroundColorA shadow-base rounded-8 px-20 py-16 mb-16"
    >
      <pre
        className="border-1 border-borderColor7 rounded-8 p-16 mb-16"
        ref={codeBlockRef}
      >
        {/* 
        show 8 lines of code in code block:
        (14 * 1.6) * 8 = 
        179.20000000000002 
        */}
        <code
          className={`${track.slug} block max-h-[180px] overflow-hidden `}
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
        users={approach.users}
        className="text-textColor1 font-semibold text-14"
      />
    </a>
  )
}
