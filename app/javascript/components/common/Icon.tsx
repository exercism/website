import * as React from 'react'
import { IconCategory, loadIconFile } from '../../utils/icon-file'

export function Icon({
  icon,
  alt,
  className,
  category = 'icons',
}: {
  icon: string
  alt: string
  className?: string
  category?: IconCategory
}): JSX.Element {
  const classNames = ['c-icon']
  if (className !== undefined) {
    classNames.push(className)
  }
  const iconFile = loadIconFile(icon, category)

  return <img src={iconFile} alt={alt} className={classNames.join(' ')} />
}
