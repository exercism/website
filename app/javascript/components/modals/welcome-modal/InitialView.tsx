import React, { useContext } from 'react'
import { WelcomeModalContext } from './WelcomeModal'

export function InitialView() {
  const { setCurrentView, patchUserSeniority } = useContext(WelcomeModalContext)
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
          className="view-changer-btn"
          onClick={() => {
            setCurrentView('beginner')
            patchUserSeniority.mutation(0)
          }}
        >
          Absolute Beginner
        </button>
        <button
          type="button"
          className="view-changer-btn"
          onClick={() => setCurrentView('beginner')}
        >
          Beginner
        </button>
        <button
          type="button"
          className="view-changer-btn"
          onClick={() => setCurrentView('developer')}
        >
          Junior Developer
        </button>
        <button
          type="button"
          className="view-changer-btn"
          onClick={() => setCurrentView('developer')}
        >
          Mid-level Developer
        </button>{' '}
        <button
          type="button"
          className="view-changer-btn"
          onClick={() => setCurrentView('developer')}
        >
          Senior Developer
        </button>
      </div>
    </div>
  )
}
