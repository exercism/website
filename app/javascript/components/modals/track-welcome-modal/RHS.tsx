import React, { useContext } from 'react'
import VimeoEmbed from '@/components/common/VimeoEmbed'
import { TrackContext } from './TrackWelcomeModal'

export function TrackWelcomeModalRHS(): JSX.Element {
  const { track } = useContext(TrackContext)
  return (
    <div className="rhs">
      <div className="rounded-8 p-20 bg-backgroundColorD border-1 border-borderColor7">
        <VimeoEmbed
          className="rounded-8 mb-16"
          id={
            track.course ? '903381063?h=bb0a6316bf' : '903384161?h=91c7b9a795'
          }
        />
        <span className="font-medium text-16 leading-150">
          ☝️ Watch this short video to learn more about Learning and Practice
          Modes, and how to choose the right setup for you.
        </span>
      </div>
    </div>
  )
}
