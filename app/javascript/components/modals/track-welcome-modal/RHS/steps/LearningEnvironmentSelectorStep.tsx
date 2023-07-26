import React, { useContext } from 'react'
import { TrackContext } from '../..'

export function LearningEnvironmentSelectorStep({
  onSelectLocalMachine,
  onSelectOnlineEditor,
  onGoBack,
}: Record<
  'onSelectLocalMachine' | 'onSelectOnlineEditor' | 'onGoBack',
  () => void
>): JSX.Element {
  const track = useContext(TrackContext)
  return (
    <>
      <header>
        <h1 className="text-h1">Welcome to {track.title}! 💙</h1>
        <p>
          You can solve the exercises on our {track.title} track either within
          our online editor, or locally within your own environment. If you use
          your own environment, you&apos;ll need to install both {track.title}{' '}
          and the Exercism CLI. How would you like to solve the Prolog
          exercises.
        </p>
      </header>
      <p>Would you like to use the track in learning mode or practice mode?</p>

      <div className="flex gap-12 items-center">
        <button onClick={onGoBack} className="btn-primary btn-l">
          Go back
        </button>
        <button onClick={onSelectOnlineEditor} className="btn-primary btn-l">
          In the online editor
        </button>
        <button onClick={onSelectLocalMachine} className="btn-primary btn-l">
          On my local machine
        </button>
      </div>
    </>
  )
}
