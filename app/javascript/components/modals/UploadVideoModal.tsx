import React from 'react'
import { Modal } from './Modal'

export function UploadVideoModal(): JSX.Element {
  return (
    <Modal open onClose={() => console.log('hello')}>
      <h2 className="text-h2">Submit a community workthrough</h2>
      <p className="text-prose">
        Produced a video of working through this exercise yourself? Want to
        share it with the Exercism community?{' '}
        <strong className="font-medium text">
          Submit the form below and Jonathan (our community manager) will review
          and approve it.
        </strong>
      </p>

      <div className="bg-gray border-2 border-gradient rounded-100">
        <div className="text-h5">Asteroid Exploration Co.</div>
        <div className="textColor-6 font-normal leading-150 text-16">Ruby</div>
      </div>

      <label
        htmlFor="video-url"
        className="text-label text-btnBorder flex flex-col"
      >
        PASTE YOUR VIDEO URL (YOUTUBE / VIMEO)
        <input
          type="text"
          name="video-url"
          placeholder="This is placeholder text"
        />
      </label>

      <button className="w-full btn-primary btn-l">Retrieve video</button>
    </Modal>
  )
}
