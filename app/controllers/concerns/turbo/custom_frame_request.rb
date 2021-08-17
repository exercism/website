module Turbo::CustomFrameRequest
  extend Turbo::Frames::FrameRequest
  extend ActiveSupport::Concern

  included do
    layout -> { 'turbo_frame' if turbo_frame_request? }
  end
end
