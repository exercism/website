import React, { useCallback, useState } from 'react'
import { flushSync } from 'react-dom'
import toast from 'react-hot-toast'
import { ConfirmationModal } from '../../common/ConfirmationModal'
import { fetchWithParams, handleJsonErrorResponse } from '../../fetchWithParams'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { SectionHeader } from '../../common/SectionHeader'
import { assembleClassNames } from '@/utils/assemble-classnames'

export function FileStructureSection() {
  const { links, isUserInsider, syncer, defaultPathTemplate } =
    React.useContext(GitHubSyncerContext)

  const [pathTemplate, setPathTemplate] = useState<string>(
    syncer?.pathTemplate || defaultPathTemplate
  )
  const [isRevertPathTemplateModalOpen, setIsRevertPathTemplateModalOpen] =
    useState(false)

  const [isTemplateInvalid, setIsTemplateInvalid] = useState<boolean>(false)

  const handleSaveChanges = useCallback(
    (template: string) => {
      if (!isUserInsider) return

      if (!isPathTemplateValid(template)) {
        setIsTemplateInvalid(true)
        return
      } else {
        setIsTemplateInvalid(false)
      }

      fetchWithParams({
        url: links.settings,
        params: {
          path_template: template,
        },
      })
        .then(async (response) => {
          if (response.ok) {
            toast.success('Saved changes successfully!')
          } else {
            await handleJsonErrorResponse(response, 'Failed to save changes.')
          }
        })
        .catch((error) => {
          console.error('Error:', error)
          toast.error(
            'Something went wrong while saving changes. Please try again.'
          )
        })
    },
    [isUserInsider, links.settings]
  )

  const handleRevertPathTemplate = useCallback(() => {
    flushSync(() => {
      setPathTemplate(defaultPathTemplate)
    })
    handleSaveChanges(defaultPathTemplate)
    setIsRevertPathTemplateModalOpen(false)
  }, [defaultPathTemplate, handleSaveChanges])

  return (
    <section className={isUserInsider ? '' : 'disabled'}>
      <SectionHeader title="File structure" />
      <p className="text-18 leading-150 mb-16">
        Use this option to configure the folder structure for your repository.
      </p>
      <p className="text-16 leading-150 mb-12">
        You can use the following placeholder values, which will be interpolated
        for each commit:
      </p>

      <ul className="text-16 leading-150 mb-16">
        <li>
          <code>$track_slug</code>: The slug of the track (e.g. "csharp").
        </li>
        <li>
          <code>$track_title</code>: The name of the track (e.g. "C#")
        </li>
        <li>
          <code>$exercise_slug</code>: The slug of the exercise (e.g.
          "hello-world")
        </li>
        <li>
          <code>$exercise_title</code>: The name of the exercise (e.g. "Hello
          World")
        </li>
        <li>
          <code>$iteration_idx</code>: The iteration index of the exercise (e.g.
          "1")
        </li>
      </ul>
      <input
        type="text"
        value={pathTemplate}
        style={{ color: !isUserInsider ? '#aaa' : '' }}
        className={assembleClassNames(
          'font-mono font-semibold text-16 leading-140 border border-1 w-full mb-16',
          isTemplateInvalid && 'border-orange!'
        )}
        onChange={(e) => {
          setPathTemplate(e.target.value)
          setIsTemplateInvalid(false)
        }}
      />
      <p className="text-16 leading-150 mb-12">
        <strong className="font-medium">Note 1:</strong> Your path must contain
        a track placeholder (<code>$track_slug</code> or{' '}
        <code>$track_title</code>) and an exercise placeholder (
        <code>$exercise_slug</code> or <code>$exercise_title</code>.
      </p>
      <p className="text-16 leading-150 mb-16">
        <strong className="font-medium">Note 2:</strong> The
        <code>$iteration_idx</code> placeholder is optional, but if you omit it,
        each iteration will override the previous one. This allows you to use
        Git for version controlling your solutions. Including the iteration
        index will result in a different folder for every iteration.
      </p>

      {isTemplateInvalid && (
        <div className="text-orange font-semibold mb-16">
          Your path template must include either <code>$track_slug</code> or{' '}
          <code>$track_title</code>, and either <code>$exercise_slug</code> or{' '}
          <code>$exercise_title</code>.
        </div>
      )}

      <div className="flex gap-8">
        <button
          disabled={!isUserInsider}
          className="btn btn-primary"
          onClick={() => handleSaveChanges(pathTemplate)}
        >
          Save changes
        </button>

        <button
          disabled={!isUserInsider || pathTemplate === defaultPathTemplate}
          className="btn btn-secondary"
          onClick={() => setIsRevertPathTemplateModalOpen(true)}
        >
          Revert to default
        </button>
      </div>
      <ConfirmationModal
        title="Are you sure you want to revert your path template to default?"
        confirmLabel="Revert"
        declineLabel="Cancel"
        onConfirm={handleRevertPathTemplate}
        open={isRevertPathTemplateModalOpen}
        onClose={() => setIsRevertPathTemplateModalOpen(false)}
      />
    </section>
  )
}

function isPathTemplateValid(pathTemplate: string): boolean {
  const hasTrackPlaceholder =
    pathTemplate.includes('$track_slug') ||
    pathTemplate.includes('$track_title')

  const hasExercisePlaceholder =
    pathTemplate.includes('$exercise_slug') ||
    pathTemplate.includes('$exercise_title')

  return hasTrackPlaceholder && hasExercisePlaceholder
}
