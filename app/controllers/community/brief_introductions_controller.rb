class Community::BriefIntroductionsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @latest_id = "QRiGxABlM-0" # WASM
    @ids = [
      "SVthw_d9nwE", # C
      "9RL8ZssWg5Q", # C++
      "xVl1NZaJYIg", # C#
      "8DgYr-V5xkg", # Elixir
      "yUPMVgvl4vo", # Gleam
      "LajgcyqjWOs", # Go
      "OuFcEQJs34w", # Haskell
      "AOF9njfbfnY", # F#
      "X4Alzh3QyWU", # Julia
      "rYDRCNFtRq0", # Nim
      "dKn-BbS_zQQ", # Prolog
      "Jbp4l_7kYxE", # Python
      "E_eH_fsXKH0", # Scala
      "zoGruqFThFE", # Swift
      "WQ-Lusoda_8", # R
      "kwEgGWXSdLM", # Rust
      "QRiGxABlM-0" # WebAssembly
    ]
  end
end
