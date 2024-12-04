import React, { useContext } from 'react'
import { TrackContext } from '../TrackWelcomeModal'

export function BootcampRecommendationView() {
  const { hideBootcampRecommendationView } = useContext(TrackContext)
  return (
    <div className="grid grid-cols-2 gap-12 items-center">
      <h2>You might find the Bootcamp is a better fit</h2>

      <p>Here's why:</p>

      <div className="grid grid-cols-2 gap-12 items-center">
        <a className="btn-m btn-primary">Go to bootcamp</a>
        <button
          onClick={hideBootcampRecommendationView}
          className="btn-m btn-secondary"
        >
          Continue anyway
        </button>
      </div>
    </div>
  )
}
