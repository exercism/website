import React, { useCallback, useState } from 'react'
import { fetchWithParams } from './fetchWithParams'
import { GitHubSyncerContext } from './GitHubSyncerForm'
import { ConfirmationModal } from './ConfirmationModal'

const DEFAULT = ''
export function PathTemplateSection() {
  const { links } = React.useContext(GitHubSyncerContext)

  const [pathTemplate, setPathTemplate] = useState<string>('')
  const [isRevertPathTemplateModalOpen, setIsRevertPathTemplateModalOpen] =
    useState(false)

  const handleRevertPathTemplate = useCallback(() => {
    setPathTemplate(DEFAULT)
    handleSaveChanges()
    setIsRevertPathTemplateModalOpen(false)
  }, [])

  const handleSaveChanges = useCallback(() => {
    fetchWithParams({
      url: links.settings,
      params: {
        path_template: pathTemplate,
      },
    })
      .then((response) => {
        if (response.ok) {
          console.log('Path template was updated successfully')
        } else {
          console.error('Failed to save changes!')
        }
      })
      .catch((error) => {
        console.error('Error:', error)
      })
  }, [pathTemplate, links.settings])

  return (
    <section>
      <h2 className="!mb-6">Folder structure</h2>
      <p className="text-18 leading-150 mb-16">
        Use this option to configure the folder structure for your repository.
      </p>
      <p className="text-16 leading-150 mb-12">
        You can use the following placeholder values, which will be interpolated
        for each commit:
      </p>

      <ul className="text-16 leading-150 mb-16">
        <li>
          <code>$track_slug</code> (mandatory): The slug of the track (e.g.
          "csharp").
        </li>
        <li>
          <code>$track_name</code> (mandatory): The name of the track (e.g.
          "C#")
        </li>
        <li>
          <code>$exercise_slug</code> (mandatory): The slug of the exercise
          (e.g. "hello-world")
        </li>
        <li>
          <code>$exercise_name</code> (mandatory): The name of the exercise
          (e.g. "Hello World")
        </li>
        <li>
          <code>$iteration_idx</code> (optional): The iteration index of the
          exercise (e.g. "1")
        </li>
      </ul>
      <input
        type="text"
        className="font-mono font-semibold text-16 leading-140 border border-1 w-full mb-16"
        onChange={(e) => setPathTemplate(e.target.value)}
      />
      <p className="text-16 leading-150 mb-16">
        <strong className="font-medium">Note:</strong> If you omit the{' '}
        <code>$iteration_idx</code>, each iteration will override the previous
        one. This allows you to use Git for version controlling your solutions.
        Including the iteration index will result in a different folder for
        every iteration.
      </p>

      <div className="flex gap-8">
        <button className="btn btn-primary" onClick={handleSaveChanges}>
          Save changes
        </button>

        <button
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
