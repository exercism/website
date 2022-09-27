import React from 'react'
import { ExerciseIcon, TrackIcon } from '../common'
import { Modal } from './Modal'

export function UploadVideoModal(): JSX.Element {
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

      <div className="py-8 px-24 bg-gray border-2 border-gradient rounded-100 flex flex-row items-center mb-32">
        <TrackIcon
          iconUrl="https://dg8krxphbh767.cloudfront.net/tracks/rust.svg"
          title="Rust"
          className="h-[40px], w-[40px] mr-12"
        />
        <ExerciseIcon
          iconUrl="https://dg8krxphbh767.cloudfront.net/exercises/amusement-park.svg"
          className="h-48 mr-12"
        />
        <div className="flex flex-col">
          <div className="text-h5">Amusement Park</div>
          <div className="textColor-6 font-normal leading-150 text-16">
            Rust
          </div>
        </div>
      </div>

      <label
        htmlFor="video-url"
        className="text-label text-btnBorder flex flex-col mb-16"
      >
        <span className="mb-8">PASTE YOUR VIDEO URL (YOUTUBE / VIMEO)</span>
        <input
          type="text"
          name="video-url"
          placeholder="This is placeholder text"
          className="font-body"
        />
      </label>

      <div className="flex">
        <button className="w-full btn-primary btn-l grow">
          Retrieve video
        </button>
      </div>
    </Modal>
  )
}
