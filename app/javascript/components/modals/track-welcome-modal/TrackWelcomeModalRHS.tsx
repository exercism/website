import React, { useContext } from 'react'
import VimeoEmbed from '@/components/common/VimeoEmbed'
import { TrackContext } from './TrackWelcomeModal'
import { Track } from '@/components/types'

export function TrackWelcomeModalRHS(): JSX.Element {
  const { track, currentState } = useContext(TrackContext)

  return <VideoStepView track={track} />
}

function VideoStepView({ track }: { track: Track }): JSX.Element {
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

function WhoIsThisTrackForView({ track }: { track: Track }): JSX.Element {
  return (
    <div className="rhs">
      <h2 className="text-h2 mb-16">Who is this track for?</h2>
      <p className="mb-16">
        {track.title} is for developers who are new to {track.title} and want to
        learn the basics. If you're already familiar with {track.title}, you
        might want to skip this track.
      </p>
      <p className="mb-16">
        If you're not sure, it's a good idea to start with the Learning Mode.
        This mode will guide you through the basics and help you get up to
        speed.
      </p>
    </div>
  )
}
