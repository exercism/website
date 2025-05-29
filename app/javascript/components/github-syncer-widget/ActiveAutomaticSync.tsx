import React from 'react'

// Syncer enabled + automatic: Say "Your solution will auto-backup to GitHub. If it does not for some reason, please click this button to manually start the backup."
export function ActiveAutomaticSync() {
  return (
    <div className="flex flex-col items-center py-24">
      <h6 className="font-semibold text-16 mb-16">
        Your solution will auto-backup to GitHub.
      </h6>
      <p className="text-center text-balance mb-16">
        If it does not for some reason, please click this button to manually
        start the backup.
      </p>
      <button className="btn btn-xs btn-primary">Start backup</button>
    </div>
  )
}
