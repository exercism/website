import React, { useCallback, useContext } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { Icon } from '@/components/common'
import RadioButton from '@/components/mentoring/representation/right-pane/RadioButton'
import { DigDeeperDataContext } from '@/components/track/DigDeeper'
import { ErrorBoundary, useErrorHandler } from '@/components/ErrorBoundary'
import type { CommunityVideoType } from '@/components/types'
import { UploadVideoTextInput } from '.'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type UploadVideoFormProps = {
  data: CommunityVideoType
  onUseDifferentVideoClick: () => void
  onSuccess: () => void
}

const DEFAULT_ERROR = new Error(
  'There was an error uploading this video. Please try again!'
)

const ErrorMessage = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

const ErrorFallback = ({ error }: { error: Error }) => {
  return (
    <div className="c-alert--danger text-16 font-body my-16 normal-case">
      {error.message}
    </div>
  )
}

export function UploadVideoForm({
  data,
  onUseDifferentVideoClick,
  onSuccess,
}: UploadVideoFormProps): JSX.Element {
  const { links, track, exercise } = useContext(DigDeeperDataContext)
  const { t } = useAppTranslation('components/modals/upload-video/elements')

  async function UploadVideo(body: string) {
    const { fetch } = sendRequest({
      endpoint: links.video.create,
      body,
      method: 'POST',
    })
    return fetch
  }

  const { mutate: uploadVideo, error } = useMutation({
    mutationFn: async (body: string) => UploadVideo(body),
    onSuccess,
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

      <button
        type="button"
        onClick={onUseDifferentVideoClick}
        className="btn-m btn-default shadow-xsZ1v2 border-borderLight2 text-textColor6 mb-16"
      >
        <Icon icon="reset" alt="Reset" className="!ml-0" />
        {t('uploadVideoForm.useDifferentVideo')}
      </button>

      <UploadVideoTextInput
        name="video_url"
        label={t('uploadVideoTextInput.pasteYourVideoUrlYoutube')}
        defaultValue={data.url}
        readOnly
      />

      <UploadVideoTextInput
        name="title"
        label={t('uploadVideoTextInput.videoTitle')}
        placeholder={t('uploadVideoTextInput.enterTheVideoTitle')}
        className="mb-24"
        defaultValue={data.title}
      />

      <fieldset className="flex flex-row font-body mb-32">
        <legend className="text-label text-btnBorder mb-16">
          {t('uploadVideoForm.isTheVideoYoursOrSomeoneElses')}
        </legend>
        <RadioButton
          className="mr-24"
          labelClassName="text-16"
          name="submitter_is_author"
          label={t('uploadVideoForm.mine')}
          value="true"
          defaultChecked
        />
        <RadioButton
          name="submitter_is_author"
          label={t('uploadVideoForm.someoneElse')}
          value="false"
          labelClassName="text-16"
        />
      </fieldset>

      <ErrorBoundary FallbackComponent={ErrorFallback}>
        <ErrorMessage error={error} />
      </ErrorBoundary>

      <div className="flex">
        <button type="submit" className="w-full btn-primary btn-l grow">
          {t('uploadVideoForm.submitVideo')}
        </button>
      </div>
    </form>
  )
}
