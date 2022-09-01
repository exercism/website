import React from 'react'
import { GraphicalIcon } from '../../../common'

export default function AlertText({ text }: { text: string }): JSX.Element {
  return (
    <div className="font-semibold text-16 text-alert flex flex-row items-center mb-[12px]">
      <GraphicalIcon className="w-[24px] h-[24px] mr-[16px]" icon="red-alert" />
      {text}
    </div>
  )
}
