import React from 'react'
import manifest from '../../.manifest.json'

console.log(manifest)

export function GraphicalIcon({
  icon,
  className = '',
  category,
  hex = false,
}: {
  icon: string
  className?: string
  category?: string
  hex?: boolean
}) {
  const classNames = ['c-icon', className, hex ? '--hex' : ''].filter(
    (className) => className.length > 0
  )

  const iconFile = manifest[`${category || 'icons'}/${icon}.svg`]
  const assetHost = 'assets/'

  return hex ? (
    <div className={classNames.join(' ')}>
      <img src={`${assetHost}${iconFile}`} alt="" role="presentation" />
    </div>
  ) : (
    <img
      src={iconFile}
      alt=""
      role="presentation"
      className={classNames.join(' ')}
    />
  )
}
