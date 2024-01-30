import React, { useContext } from 'react'
import { DigDeeperDataContext } from '../DigDeeper'
import { YouTubePlayer } from '@/components/common/YoutubePlayer'

export function DeepDiveVideo() {
  const { exercise } = useContext(DigDeeperDataContext)
  if (!exercise || !exercise.deepDiveYoutubeId) {
    return null
  }

  return (
    <div className="mb-32 bg-backgroundColorA shadow-lg rounded-8 px-20 lg:px-32 py-20 lg:py-24">
      <h3 className="text-h3 mb-8">Deep Dive into {exercise.title}!</h3>
      <p className="text-p-large mb-16">
        Take a deep dive into {exercise.title} with Jeremy and Erik, as they
        explore the different ways this exercise can be solved and dig into some
        interesting community solutions.
      </p>
      <div className="w-[100%]">
        <YouTubePlayer id={exercise.deepDiveYoutubeId} />
      </div>
    </div>
  )
}
