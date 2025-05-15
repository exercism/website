import React, { useCallback } from 'react'
import { fetchWithParams } from './fetchWithParams'
import { GitHubSyncerContext } from './GitHubSyncerForm'

export function CommitMessageTemplateSection() {
  const { links } = React.useContext(GitHubSyncerContext)

  const [commitMessageTemplate, setCommitMessageTemplate] =
    React.useState<string>('')

  const handleSaveChanges = useCallback(() => {
    fetchWithParams({
      url: links.settings,
      params: {
        commit_message_template: commitMessageTemplate,
      },
    })
      .then((response) => {
        if (response.ok) {
          console.log('Commit message template was updated successfully')
        } else {
          console.error('Failed to save changes')
        }
      })
      .catch((error) => {
        console.error('Error:', error)
      })
  }, [commitMessageTemplate, links.settings])

  return (
    <section>
      <h2>Commit message template</h2>
      <p className="text-16 leading-140 mb-16">
        Set up a commit/PR message template
      </p>

      <button className="btn btn-primary" onClick={handleSaveChanges}>
        Save changes
      </button>
    </section>
  )
}
