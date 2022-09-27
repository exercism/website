import React from 'react'
import { Modal } from '../Modal'
import {
  ExerciseTrackIndicator,
  UploadVideoTextInput,
  UploadVideoControl,
} from './elements'

type UploadVideoModalProps = {
  videoSubmitted: boolean
}

export function UploadVideoModal({
  videoSubmitted = false,
}: UploadVideoModalProps): JSX.Element {
  return (
    <Modal
      open
      onClose={() => console.log('hello')}
      ReactModalClassName="max-w-[780px]"
    >
      <h2 className="text-h2 mb-8">Submit a community workthrough</h2>
      <p className="text-prose mb-24">
        Produced a video of working through this exercise yourself? Want to
        share it with the Exercism community?{' '}
        <strong className="font-medium text">
          Submit the form below and Jonathan (our community manager) will review
          and approve it.
        </strong>
      </p>

      <ExerciseTrackIndicator
        exercise="Amusement Park"
        exerciseIconUrl="https://dg8krxphbh767.cloudfront.net/exercises/amusement-park.svg"
        track="Rust"
        trackIconUrl="https://dg8krxphbh767.cloudfront.net/tracks/rust.svg"
        videoSubmitted={videoSubmitted}
      />

      {/* TODO: Componentize this */}
      {videoSubmitted && (
        <iframe
          src="https://www.youtube.com/watch?v=VJ5XkzbG-BI&ab_channel=Exercism"
          height="360"
          width="100%"
          className="rounded-16 mb-16"
        ></iframe>
      )}

      <UploadVideoTextInput
        label="PASTE YOUR VIDEO URL (YOUTUBE / VIMEO)"
        disabled={videoSubmitted}
      />

      {videoSubmitted ? (
        <UploadVideoControl />
      ) : (
        <div className="flex">
          <button className="w-full btn-primary btn-l grow">
            Retrieve video
          </button>
        </div>
      )}
    </Modal>
  )
}
