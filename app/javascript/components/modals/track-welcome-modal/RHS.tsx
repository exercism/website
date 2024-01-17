import React, { useContext } from 'react'
import { Choices } from './LHS/steps/components/Choices'
import VimeoEmbed from '@/components/common/VimeoEmbed'
import { TrackContext } from './WelcomeTrackModal'

export function TrackWelcomeModalRHS(): JSX.Element {
  const { track } = useContext(TrackContext)
  return (
    <div className="rhs">
      <VimeoEmbed
        className="rounded-8 mb-16"
        id={track.course ? '903381063?h=bb0a6316bf' : '903384161?h=91c7b9a795'}
      />
      <Choices />
    </div>
  )
}
