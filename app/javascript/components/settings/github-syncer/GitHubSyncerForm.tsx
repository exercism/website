import React, { useCallback } from 'react'

export type GitHubSyncerFormProps = {
  links: { connectToGithub: string; settings: string }
  isUserConnected: boolean
  isUserActive: boolean
}

type GitHubSyncerContextType = {
  links: GitHubSyncerFormProps['links']
  isUserActive: GitHubSyncerFormProps['isUserActive']
}
const GitHubSyncerContext = React.createContext<GitHubSyncerContextType>(
  {} as GitHubSyncerContextType
)

export default function GitHubSyncerForm(
  data: GitHubSyncerFormProps
): JSX.Element {
  console.log('DATA', data)

  return (
    <GitHubSyncerContext.Provider
      value={{ links: data.links, isUserActive: data.isUserActive }}
    >
      {data.isUserConnected ? <ConnectedSection /> : <ConnectToGithubSection />}
    </GitHubSyncerContext.Provider>
  )
}

function ConnectToGithubSection() {
  const { links } = React.useContext(GitHubSyncerContext)
  return (
    <section>
      <h2>Connect to GitHub</h2>
      <p className="text-16 leading-140 mb-16">
        Connect to GitHub to sync your repositories.
      </p>
      <a className="btn btn-primary w-fit" href={links?.connectToGithub}>
        Connect to GitHub repo
      </a>
    </section>
  )
}

function ConnectedSection() {
  return <DangerZoneSection />
}

function DangerZoneSection() {
  const { links, isUserActive } = React.useContext(GitHubSyncerContext)

  const handleToggleActivity = useCallback(() => {
    fetchWithParams({ url: links.settings, params: { active: !isUserActive } })
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
  }, [isUserActive, links.settings])

  const handleDelete = useCallback(() => {
    fetchWithParams({ url: links.settings, method: 'DELETE' })
      .then((response) => {
        if (response.ok) {
          console.log('Deleted successfully')
        } else {
          console.error('Failed to delete')
        }
      })
      .catch((error) => {
        console.error('Error:', error)
      })
  }, [links.settings])

  return (
    <section className="border border-2 border-danger">
      <h2>Danger Zone</h2>
      <p className="text-16 leading-140 mb-16">
        This is a dangerous zone. Be careful.
      </p>
      <div className="flex gap-8">
        <button onClick={handleToggleActivity} className="btn">
          {isUserActive ? 'Pause' : 'Resume'}
        </button>
        <button onClick={handleDelete} className="btn">
          Delete
        </button>
      </div>
    </section>
  )
}

function fetchWithParams({
  url,
  params,
  method = 'GET',
}: {
  url: string
  params?: Record<string, string | number | boolean>
  method?: 'GET' | 'DELETE'
}): Promise<Response> {
  const query = params
    ? '?' +
      new URLSearchParams(
        Object.entries(params).reduce((acc, [key, val]) => {
          acc[key] = String(val)
          return acc
        }, {} as Record<string, string>)
      ).toString()
    : ''

  return fetch(url + query, { method })
}
