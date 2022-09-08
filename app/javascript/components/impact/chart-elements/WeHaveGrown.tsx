import React from 'react'
import { GraphicalIcon } from '../../common'

export function WeHaveGrown(): JSX.Element {
  return (
    <div className="absolute top-[49px] left-[20%] flex flex-col w-[60%] text-center ">
      <GraphicalIcon
        className="mb-16 mx-auto"
        height={67}
        width={64}
        icon="graph-stats-ascend"
      />
      <h2 className="text-h1 leading-[132%] text-white mb-16">
        We&apos;ve grown to over 1M students entirely by word of mouth.
      </h2>
      <p className="text-gray text-p-2xlarge">
        We work closely with our community to understand how to evolve Exercism
        to be the best it can be, and they reward us by sharing with their
        friends.
      </p>
    </div>
  )
}
