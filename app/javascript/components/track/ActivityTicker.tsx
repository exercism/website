import React from 'react'

export default function ActivityTicker({ trackTitle }) {
  return (
    <section className="live-section">
      <h3 className="text-h4 mb-8">Now on the {trackTitle} track</h3>

      <div className="flex items-start">
        <img
          src="path_to_image/team/jeremy-walker.jpg"
          alt="Jeremy Walker"
          className="w-[36px] h-[36px] rounded-circle mr-12 mt-4"
        />
        <div className="flex flex-col">
          <div className="text-16 leading-140 mb-4">
            <a href="#" className="text-linkColor font-semibold">
              @iHiD
            </a>{' '}
            published a{' '}
            <a href="#" className="text-linkColor font-semibold">
              new solution
            </a>{' '}
            to Some Really Long Exercise Name.
          </div>
          <div className="text-14 text-textColor7">25 minutes ago</div>
        </div>
      </div>
    </section>
  )
}
