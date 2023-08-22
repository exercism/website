import React from 'react'
import { useDropdown } from './useDropdown'

type MenuButton = {
  label: string
  className: string
  extraClassNames?: string[]
  html: string
}

type MenuItem = {
  html: string
  className: string
}

export default function Dropdown({
  menuButton,
  menuItems,
}: {
  menuButton: MenuButton
  menuItems: MenuItem[]
}): JSX.Element {
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    open,
  } = useDropdown(menuItems.length, undefined, {
    placement: 'bottom-start',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [0, 8],
        },
      },
    ],
  })

  return (
    <React.Fragment>
      <button
        className={`${menuButton.className} ${
          menuButton.extraClassNames ? menuButton.extraClassNames.join(' ') : ''
        }`}
        dangerouslySetInnerHTML={{ __html: menuButton.html }}
        aria-label={menuButton.label}
        {...buttonAttributes}
      />
      {open ? (
        <div {...panelAttributes}>
          <ul
            className={`${menuButton.className}-dropdown`}
            {...listAttributes}
          >
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
      ) : null}
    </React.Fragment>
  )
}
