import React, { useContext } from 'react'
import { WelcomeModalContext, VIEW_CHANGER_BUTTON_CLASS } from './WelcomeModal'

export function JuniorView() {
  const { setCurrentView } = useContext(WelcomeModalContext)
  return (
    <div className="lhs">
      <header>
        <h1>Welcome to Exercism! 💙</h1>

        <p className="">Join our bootcamp!</p>
      </header>
      <button
        type="button"
        className={VIEW_CHANGER_BUTTON_CLASS}
        onClick={() => setCurrentView('initial')}
      >
        Back
      </button>
    </div>
  )
}
