require 'set'

module Git
  class SyncTrack
    include Mandate
    initialize_with :track

    def call
      guard!
      lookup_head_and_current_commit
      update_track! if track_files_modified?
    end

    private
    attr_reader :current_commit, :head_commit

    def guard!
      raise TrackNotFoundError unless track
    end

    def lookup_head_and_current_commit
      track.git.send(:repo).update!

      @current_commit = track.git.send(:repo).lookup_commit(track.git_sha)
      @head_commit = track.git.send(:repo).head_commit
    end

    def track_files_modified?
      return false if current_commit.oid == head_commit.oid

      diff = head_commit.diff(current_commit)
      diff.each_delta.any? do |delta|
        delta.old_file[:path] == track.git.config_file ||
          delta.new_file[:path] == track.git.config_file
      end
    end

    def update_track!
      # TODO: consider raising error when slug in config is different from track slug

      head_config = track.git.config(commit: head_commit)

      track.blurb = head_config[:blurb]
      track.active = head_config[:active]
      track.title = head_config[:language]

      # TODO: validate track to prevent invalid track data

      track.git_sha = head_commit.oid if track.changed?
      track.save
    end
  end
end
