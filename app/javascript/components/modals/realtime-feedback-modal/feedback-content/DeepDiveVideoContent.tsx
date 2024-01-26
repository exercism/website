import React from 'react'
import { ContinueButton } from '../components/FeedbackContentButtons'
import { YouTubePlayer } from '@/components/common/YoutubePlayer'

export function DeepDiveVideoContent({ exercise, onContinue }) {
  return (
    <>
      <h3 className="text-h3 mb-8">Deep Dive into {exercise.title}!</h3>
      <p className="text-p-large mb-16">
        Take a deep dive into {exercise.title} with Jeremy and Erik, as they
        explore the different ways this exercise can be solved and dig into some
        interesting community solutions.
      </p>
      <div className="w-[100%] mb-16">
        <YouTubePlayer
          id={exercise.deepDiveYoutubeId}
          onPlay={() => console.log('mark video as seen')}
        />
      </div>
      <ContinueButton text={'Continue'} onClick={onContinue} />
    </>
  )
}
