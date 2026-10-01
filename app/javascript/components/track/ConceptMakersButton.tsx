import React, { useState } from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Avatar } from '../common'
import { ConceptMakersModal } from '../modals/ConceptMakersModal'

type Links = {
  makers: string
}

export function ConceptMakersButton({
  avatarUrls,
  numAuthors,
  numContributors,
  links,
}: {
  avatarUrls: readonly string[]
  numAuthors: number
  numContributors: number
  links: Links
}): JSX.Element {
  const { t } = useAppTranslation('components/track')
  const [open, setOpen] = useState(false)

  return (
    <React.Fragment>
      <button
        type="button"
        className="c-makers-button"
        onClick={() => setOpen(!open)}
      >
        <div className="c-faces --static">
          {avatarUrls.map((avatarUrl) => (
            <Avatar className="face" src={avatarUrl} key={avatarUrl} />
          ))}
        </div>
        <div className="stats">
          {numAuthors > 0 ? (
            <div className="authors">
              {t('conceptMakersButton.authors', { count: numAuthors })}
            </div>
          ) : null}
          {numContributors > 0 ? (
            <div className="contributors">
              {t('conceptMakersButton.contributors', {
                count: numContributors,
              })}
            </div>
          ) : null}
        </div>
      </button>
      <ConceptMakersModal
        open={open}
        onClose={() => setOpen(false)}
        endpoint={links.makers}
      />
    </React.Fragment>
  )
}
export default ConceptMakersButton
