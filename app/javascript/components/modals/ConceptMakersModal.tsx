import React from 'react'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'
import { ModalProps, Modal } from './Modal'
import { ProminentLink, Avatar, GraphicalIcon, Reputation } from '../common'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { User } from '../types'

const DEFAULT_ERROR = new Error('Unable to load concept makers')

type Links = {
  github: string
}
type APIResponse = {
  authors: readonly User[]
  contributors: readonly User[]
  links: Links
}
const MakerInner = ({
  maker,
  showIcon,
}: {
  maker: User
  showIcon: boolean
}): JSX.Element => {
  return (
    <>
      <Avatar src={maker.avatarUrl} handle={maker.handle} />
      <div className="handle">{maker.handle}</div>
      <Reputation value={maker.reputation!} type="primary" size="small" />
      {showIcon ? (
        <GraphicalIcon icon="chevron-right" />
      ) : (
        <div className="faux-icon" />
      )}
    </>
  )
}

const Maker = ({ maker }: { maker: User }): JSX.Element => {
  return maker.links?.self ? (
    <a className="maker" href={maker.links?.self}>
      <MakerInner maker={maker} showIcon={true} />
    </a>
  ) : (
    <div className="maker">
      <MakerInner maker={maker} showIcon={false} />
    </div>
  )
}

const Content = ({
  authors,
  contributors,
  links,
}: APIResponse): JSX.Element => {
  return (
    <>
      <ProminentLink
        link={links.github}
        text="See the full history of this concept on GitHub"
        withBg={true}
        external
      />
      {authors.length > 0 ? (
        <div className="authors">
          <div className="heading">
            <h3>
              Authors <span className="count">{authors.length}</span>
            </h3>
            <div className="subtitle">People who wrote the concept</div>
          </div>

          {authors.map((author) => (
            <Maker maker={author} key={author.handle} />
          ))}
        </div>
      ) : null}

      {contributors.length > 0 ? (
        <div className="contributors">
          <div className="heading">
            <h3>
              Contributors <span className="count">{contributors.length}</span>
            </h3>
            <div className="subtitle">People who updated the concept</div>
          </div>
          {contributors.map((contributor) => (
            <Maker maker={contributor} key={contributor.handle} />
          ))}
        </div>
      ) : null}
    </>
  )
}

export const ConceptMakersModal = ({
  endpoint,
  ...props
}: { endpoint: string } & Omit<ModalProps, 'className'>): JSX.Element => {
  const {
    status,
    data: resolvedData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<APIResponse>(['concept-makers', endpoint], {
    endpoint: endpoint,
    options: { enabled: props.open },
  })

  return (
    <Modal {...props} className="m-makers">
      <ResultsZone isFetching={isFetching}>
        <FetchingBoundary
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
        >
          {resolvedData ? <Content {...resolvedData} /> : null}
        </FetchingBoundary>
      </ResultsZone>
    </Modal>
  )
}
