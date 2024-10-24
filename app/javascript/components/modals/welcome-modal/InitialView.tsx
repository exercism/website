import React, { useContext } from 'react'
import { WelcomeModalContext, VIEW_CHANGER_BUTTON_CLASS } from './WelcomeModal'

export function InitialView() {
  const { numTracks, setCurrentView } = useContext(WelcomeModalContext)
  return (
    <div className="lhs">
      <header>
        <h1>Welcome to Exercism! 💙</h1>

        <p>
          Exercism is the place to deepen your programming skills and explore
          over {numTracks} programming languages. It&apos;s 100% free.
        </p>
      </header>

      <h3 className="text-h3 mb-16">Which one are you?</h3>
      <div className="flex items-center gap-8">
        <button
          type="button"
          className={VIEW_CHANGER_BUTTON_CLASS}
          onClick={() => setCurrentView('junior')}
        >
          Complete beginner
        </button>
        <button
          type="button"
          className={VIEW_CHANGER_BUTTON_CLASS}
          onClick={() => setCurrentView('senior')}
        >
          Lead architect
        </button>
      </div>
    </div>
  )
}
