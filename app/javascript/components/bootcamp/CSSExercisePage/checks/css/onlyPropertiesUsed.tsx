import React from 'react'
import GraphicalIcon from '@/components/common/GraphicalIcon'
import postcss from 'postcss'
import postcssNested from 'postcss-nested'
import toast from 'react-hot-toast'
import { assembleClassNames } from '@/utils/assemble-classnames'

export async function onlyPropertiesUsed(
  css: string,
  allowed: string[]
): Promise<boolean> {
  const usedProps = new Set<string>()

  const result = await postcss([postcssNested]).process(css, {
    from: undefined,
  })

  result.root.walkDecls((decl) => {
    usedProps.add(decl.prop)
  })

  const disallowed = [...usedProps].filter((prop) => !allowed.includes(prop))

  for (const used of usedProps) {
    if (!allowed.includes(used)) {
      showUsedPropertiesToast({ used: disallowed })
      return false
    }
  }

  return true
}

function showUsedPropertiesToast({ used }: { used: string[] }) {
  toast.custom(
    (t) => (
      <div
        className={assembleClassNames(
          t.visible ? 'animate-slideIn' : 'animate-slideOut',
          'border-danger',
          'border-1 flex bg-white shadow-base text-14 rounded-5 p-8 gap-8 items-center'
        )}
      >
        <div className={assembleClassNames('font-medium', 'text-danger')}>
          You used unpermitted params: <strong>{used.join(', ')}.</strong>
        </div>

        <button
          className="rounded-cirle bg-textColor4"
          onClick={() => toast.dismiss(t.id)}
        >
          <GraphicalIcon
            className="filter-danger"
            icon="cross"
            width={12}
            height={12}
          />
        </button>
      </div>
    ),
    { duration: 6000 }
  )
}
