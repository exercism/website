import React from 'react'
export function TooltipInformation({
  hasCodeBeenEdited,
  notEnoughFrames,
}: Record<string, boolean>) {
  // editing code removes frames anyway, so this has to be higher precedence
  if (hasCodeBeenEdited) {
    return (
      <StaticTooltip text="Scrubber is disabled because the code has been edited" />
    )
  }

  if (notEnoughFrames) {
    return (
      <StaticTooltip text="There is only one frame. You can inspect that by toggling information widget." />
    )
  }
}

function StaticTooltip({ text }: { text: string }) {
  return (
    <div
      className="absolute left-1/2 -top-10 py-4 px-8 -translate-x-1/2 -translate-y-[100%] hidden group-hover:block bg-gray-800 text-[#fafaff] text-sm rounded shadow-lg"
      role="tooltip"
    >
      {text}
    </div>
  )
}
