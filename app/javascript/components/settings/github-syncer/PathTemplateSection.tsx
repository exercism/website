import React, { useCallback } from 'react'
import { fetchWithParams } from './fetchWithParams'
import { GitHubSyncerContext } from './GitHubSyncerForm'

export function PathTemplateSection() {
  const { links } = React.useContext(GitHubSyncerContext)

  const [pathTemplate, setPathTemplate] = React.useState<string>('')

  const handleSaveChanges = useCallback(() => {
    fetchWithParams({
      url: links.settings,
      params: {
        path_template: pathTemplate,
      },
    })
      .then((response) => {
        if (response.ok) {
          console.log('Change activity status successfully')
        } else {
          console.error('Failed to change status')
        }
      })
      .catch((error) => {
        console.error('Error:', error)
      })
  }, [pathTemplate, links.settings])

  return (
    <section>
      <h2>Folder structure</h2>
      <p className="text-16 leading-140 mb-16">
        What folder structure do you want?
      </p>

      <button className="btn btn-primary" onClick={handleSaveChanges}>
        Save changes
      </button>
    </section>
  )
}
