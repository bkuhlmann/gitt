# frozen_string_literal: true

RSpec.shared_context "with Git commit" do
  let :git_commit do
    Gitt::Models::Commit[
      author_email: "test@example.com",
      author_name: "Test User",
      authored_relative_at: "1 day ago",
      body: "",
      raw: "",
      sha: "180dec7d8ae8cbe3565a727c63c2111e49e0b737",
      subject: "Added documentation",
      trailers: ""
    ]
  end
end
