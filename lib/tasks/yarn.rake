# cssbundling-rails treats yarn.lock as a bun lockfile, so any machine with bun
# on its PATH gets `bun install` from css:build's install prereq, which wipes
# node_modules and reinstalls git-sourced dependencies without building them.
# This repo is yarn-only, so pin both bundlers to yarn.
module Jsbundling
  module Tasks
    def install_command
      'yarn install'
    end

    def build_command
      'yarn build'
    end
  end
end

module Cssbundling
  module Tasks
    def install_command
      'yarn install'
    end

    def build_command
      'yarn build:css'
    end
  end
end
