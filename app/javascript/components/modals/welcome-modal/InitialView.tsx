import React, { useContext } from 'react'
import { WelcomeModalContext, VIEW_CHANGER_BUTTON_CLASS } from './WelcomeModal'

export function InitialView() {
  const { numTracks, setCurrentView } = useContext(WelcomeModalContext)
  return (
    <div className="lhs">
      <header>
        <h1 className="text-center">Welcome to Exercism! 💙</h1>

        <p className="text-center">
          Let's make sure that you get the most out of Exercism.
        </p>
        <p className="text-center">How experienced a developer are you?</p>
      </header>

      <div className="flex flex-col items-stretch gap-8">
        <button
          type="button"
          className={VIEW_CHANGER_BUTTON_CLASS}
          onClick={() => setCurrentView('beginner')}
        >
          Absolute Beginner
        </button>
        <button
          type="button"
          className={VIEW_CHANGER_BUTTON_CLASS}
          onClick={() => setCurrentView('beginner')}
        >
          Beginner
        </button>
        <button
          type="button"
          className={VIEW_CHANGER_BUTTON_CLASS}
          onClick={() => setCurrentView('developer')}
        >
          Junior Developer
        </button>
        <button
          type="button"
          className={VIEW_CHANGER_BUTTON_CLASS}
          onClick={() => setCurrentView('developer')}
        >
          Mid-level Developer
        </button>{' '}
        <button
          type="button"
          className={VIEW_CHANGER_BUTTON_CLASS}
          onClick={() => setCurrentView('developer')}
        >
          Senior Developer
        </button>
      </div>
    </div>
  )
}
