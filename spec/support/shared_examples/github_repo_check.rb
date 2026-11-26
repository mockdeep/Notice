# frozen_string_literal: true

# Specs for Check::Github::RepoCheck. The including spec must define
# `build_check(**attributes)` and `create_check`, and use the fake GitHub
# client.
RSpec.shared_examples("a GitHub repo check") do
  describe "#repo=" do
    it "keeps an owner/name value" do
      expect(build_check(repo: "rails/rails").repo).to eq("rails/rails")
    end

    it "pulls owner/name out of a GitHub URL" do
      check = build_check(repo: " https://github.com/rails/rails/pulls?q=1 ")

      expect(check.repo).to eq("rails/rails")
    end

    it "handles a URL without a scheme and a .git suffix" do
      check = build_check(repo: "github.com/rails/rails.git")

      expect(check.repo).to eq("rails/rails")
    end
  end

  describe "validation" do
    it "is valid when the repo exists" do
      check = build_check(repo: "rails/rails")
      check.validate

      expect(check.errors[:repo]).to be_empty
    end

    it "adds an error when the repo is blank" do
      check = build_check(repo: "")
      check.validate

      expect(check.errors[:repo]).to include("can't be blank")
    end

    it "adds an error when the repo is not owner/name" do
      check = build_check(repo: "rails")
      check.validate

      expect(check.errors[:repo]).to include("is invalid")
    end

    it "adds an error when GitHub can't find the repo" do
      check = build_check(repo: "rails/nope")
      check.validate

      expect(check.errors[:repo]).to include("wasn't found on GitHub")
    end

    it "does not look up the repo again when other fields change" do
      record = create_check
      check = described_class.find(record.id)
      expect(check.integration).not_to receive(:repo_exists?)

      check.update!(name: "Renamed")
    end
  end

  describe "#next_step" do
    it "returns repo when no repo is given" do
      expect(build_check.next_step).to eq("repo")
    end

    it "does not add errors when no repo is given" do
      check = build_check
      check.next_step

      expect(check.errors).to be_empty
    end

    it "returns repo when the repo is not found" do
      expect(build_check(repo: "rails/nope").next_step).to eq("repo")
    end

    it "adds one error when the repo is not found" do
      check = build_check(repo: "rails/nope")
      2.times { check.next_step }

      expect(check.errors[:repo]).to eq(["wasn't found on GitHub"])
    end

    it "returns name once the repo is found" do
      expect(build_check(repo: "rails/rails").next_step).to eq("name")
    end

    it "returns nil when all steps are done" do
      check = build_check(repo: "rails/rails", name: "Rails check")

      expect(check.next_step).to be_nil
    end
  end
end
