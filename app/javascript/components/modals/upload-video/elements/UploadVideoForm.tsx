import React, { useCallback, useContext } from 'react'
import { useMutation } from 'react-query'
import { UploadVideoTextInput, CommunityVideo } from '.'
import { sendRequest } from '@/utils/send-request'
import { Icon } from '@/components/common'
import RadioButton from '@/components/mentoring/representation/right-pane/RadioButton'
import { ApproachesDataContext } from '@/components/track/Approaches'

type UploadVideoFormProps = {
  data: CommunityVideo
  onUseDifferentVideoClick: () => void
  onSuccess: () => void
  onError: () => void
}

export function UploadVideoForm({
  data,
  onUseDifferentVideoClick,
  onSuccess,
  onError,
}: UploadVideoFormProps): JSX.Element {
  const { links, track, exercise } = useContext(ApproachesDataContext)
  async function UploadVideo(body: string) {
    const { fetch } = sendRequest({
      endpoint: links.video.create,
      body,
      method: 'POST',
    })
    return fetch
  }

  const [uploadVideo] = useMutation((body: string) => UploadVideo(body), {
    onSuccess: () => onSuccess(),
    onError: () => onError(),
  })

  const handleSubmitVideo = useCallback(
    (e: React.FormEvent<HTMLFormElement>) => {
      e.preventDefault()
      const data = new FormData(e.currentTarget)
      if (data.get('submitter_is_author') === 'false') {
        data.delete('submitter_is_author')
      }

      uploadVideo(
        JSON.stringify({
          ...Object.fromEntries(data.entries()),
          track_slug: track.slug,
          exercise_slug: exercise.slug,
        })
      )
    },
    [exercise.slug, track.slug, uploadVideo]
  )
  return (
    <form onSubmit={handleSubmitVideo}>
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
        label="PASTE YOUR VIDEO URL (YOUTUBE)"
        defaultValue={data.url}
        readOnly
      />

      <UploadVideoTextInput
        name="title"
        label="Video title"
        placeholder="Enter the video title"
        className="mb-24"
        defaultValue={data.title}
      />

      <fieldset className="flex flex-row font-body mb-32">
        <legend className="text-label text-btnBorder mb-16">
          IS THE VIDEO YOURS OR SOMEONE ELSES?
        </legend>
        <RadioButton
          className="mr-24"
          labelClassName="text-16"
          name="submitter_is_author"
          label="Mine"
          value="true"
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
