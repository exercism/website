import { GraphicalIcon, Icon } from '@/components/common'
import VimeoEmbed from '@/components/common/VimeoEmbed'
import { Track } from '@/components/types'
import React from 'react'

export function WhoIsThisTrackForRHS({ track }: { track: Track }): JSX.Element {
  return (
    <div className="rhs" data-capy-element="who-is-this-track-for-rhs">
      <div className="rounded-8 p-20 bg-backgroundColorD border-1 border-borderColor7 mb-16">
        <div className="flex flex-row gap-8 items-center justify-center text-16 text-textColor1 mb-16">
          <Icon
            icon="exercism-face"
            className="filter-textColor1"
            alt="exercism-face"
            height={16}
            width={16}
          />
          <div>
            <strong className="font-semibold"> Exercism </strong>
            Bootcamp
          </div>
        </div>
        <VimeoEmbed className="rounded-8 mb-16" id="1024390839?h=c2b3bdce14" />
        <span className="text-16 leading-150 text-textColor2">
          <strong className="font-medium">
            🗓️ The Bootcamp starts in January.{' '}
          </strong>
          Check out our introduction video (☝️) to see how it will work and if
          it's the right fit for you!
        </span>
      </div>
    </div>
  )
}
