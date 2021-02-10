import React, { KeyboardEvent } from 'react'
import { useDropdown } from './useDropdown'

type MenuButton = {
  label: string
  className: string
  html: string
}

type MenuItem = {
  html: string
  className: string
}

export const Dropdown = ({
  menuButton,
  menuItems,
}: {
  menuButton: MenuButton
  menuItems: MenuItem[]
}): JSX.Element => {
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
  } = useDropdown(menuItems.length)

  return (
    <React.Fragment>
      <button
        className={`${menuButton.className}`}
        dangerouslySetInnerHTML={{ __html: menuButton.html }}
        aria-label={menuButton.label}
        {...buttonAttributes}
      />
      <div {...panelAttributes}>
        <ul className={`${menuButton.className}-dropdown`} {...listAttributes}>
          {menuItems.map((item, i) => {
            return (
              <li
                key={i}
                dangerouslySetInnerHTML={{ __html: item.html }}
                className={item.className}
                {...itemAttributes(i)}
              />
            )
          })}
        </ul>
      </div>
    </React.Fragment>
  )
}
