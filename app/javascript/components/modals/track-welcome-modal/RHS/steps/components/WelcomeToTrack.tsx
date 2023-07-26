import React, { useContext } from 'react'
import { TrackContext } from '../../..'
export function WelcomeToTrack(): JSX.Element {
  const track = useContext(TrackContext)
  return <h1 className="text-h1">Welcome to {track.title}! 💙</h1>
}
