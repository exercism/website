import React, { useCallback } from 'react'
import { UploadVideoTextInput, CommunityVideo } from '.'
import { Icon } from '../../../common'
import RadioButton from '../../../mentoring/representation/right-pane/RadioButton'

export function UploadVideoForm({
  data,
  onUseDifferentVideoClick,
}: {
  data: CommunityVideo
  onUseDifferentVideoClick: () => void
}): JSX.Element {
  const handleSubmitVideo = useCallback(
    (e: React.FormEvent<HTMLFormElement>) => {
      e.preventDefault()
      const data = new FormData(e.currentTarget)
      if (data.get('submitter_is_author') === 'false') {
        data.delete('submitter_is_author')
      }
      console.log(Object.fromEntries(data.entries()))
    },
    []
  )
  return (
    <form
      onSubmit={handleSubmitVideo}
      onChange={(e) => console.log(e.currentTarget)}
    >
      <img
        src={data.thumbnailUrl}
        alt="video thumbnail"
        style={{ height: '360px', width: '100%', objectFit: 'cover' }}
        className="rounded-16 mb-16"
      />

      {/* btn-i-filled has a different shadow than in Figma */}
      <button
        type="button"
        onClick={onUseDifferentVideoClick}
        className="btn-m btn-default shadow-xsZ1v2 border-borderLight2 text-textColor6 mb-16"
      >
        <Icon icon="reset" alt="Reset" className="!ml-0" />
        Use different video
      </button>

      <UploadVideoTextInput
        name="video_url"
        label="PASTE YOUR VIDEO URL (YOUTUBE / VIMEO)"
        defaultValue={data.url}
        readOnly
      />

      <UploadVideoTextInput
        name="title"
        label="Video title"
        className="mb-24"
        defaultValue={data.title}
      />

      <fieldset className="flex flex-row font-body mb-32">
        <legend className="text-label text-btnBorder mb-16">
          IS THE VIDEO YOURS OR SOMEONE ELSES?
        </legend>
        <RadioButton
          name="submitter_is_author"
          label="Mine"
          value="true"
          labelClassName="text-16"
          className="mr-24"
          defaultChecked
        />
        <RadioButton
          name="submitter_is_author"
          label="Someone else"
          value="false"
          labelClassName="text-16"
        />
      </fieldset>

      {/* <div className="mb-24 text-p-base leading-150">
        Please ensure you have full rights to take credit for the video before
        submitting.
      </div> */}
      <div className="flex">
        <button type="submit" className="w-full btn-primary btn-l grow">
          Submit video
        </button>
      </div>
    </form>
  )
}
