# frozen_string_literal: true

class Views::GithubChecks::New < Views::Base
  def initialize(check:, integration:, check_type:)
    super()
    @check = check
    @integration = integration
    @check_type = check_type
  end

  def view_template
    case @check.next_step
    when "repo" then repo_step
    else name_step
    end
  end

  private

  def repo_step
    PageHeader(title: translate(:repo_title))

    div(class: "form-card") do
      form_with(model: @check, url: step_path, method: :get) do |form|
        check_type_field
        ErrorExplanation(model: @check)
        repo_field(form)
        div(class: "actions") { form.submit("Next") }
      end
    end
  end

  def repo_field(form)
    div(class: "field") do
      form.label(:repo)
      form.text_field(:repo, placeholder: translate(:repo_hint))
    end
  end

  def name_step
    url = github_integration_checks_path(@integration)

    CheckNameForm(check: @check, url:) do |form|
      check_type_field
      form.hidden_field(:repo) if @check.respond_to?(:repo)
    end
  end

  def check_type_field
    input(type: "hidden", name: "check_type", value: @check_type)
  end

  def step_path
    new_github_integration_check_path(@integration)
  end

  def translate(key)
    I18n.t(key, scope: [:views, :github_checks, :new])
  end
end
