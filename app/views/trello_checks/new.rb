# frozen_string_literal: true

class Views::TrelloChecks::New < Views::Base
  def initialize(check:, integration:)
    @check = check
    @integration = integration
  end

  def view_template
    case @check.next_step
    when "board_id" then board_id_step
    when "list_id" then list_id_step
    else name_step
    end
  end

  private

  def board_id_step
    step_form("Pick a board") do |form|
      form.label(:board_id, "Board")
      form.collection_select(:board_id, @check.fetch_boards, :id, :name)
    end
  end

  def list_id_step
    step_form("Pick a list") do |form|
      form.hidden_field(:board_id)
      form.label(:list_id, "List")
      form.collection_select(:list_id, @check.lists, :id, :name)
    end
  end

  def step_form(title)
    PageHeader(title:)

    div(class: "form-card") do
      form_with(model: @check, url: step_path, method: :get) do |form|
        div(class: "field") { yield(form) }
        div(class: "actions") { form.submit("Next") }
      end
    end
  end

  def name_step
    url = trello_integration_checks_path(@integration)

    CheckNameForm(check: @check, url:) do |form|
      form.hidden_field(:board_id)
      form.hidden_field(:list_id)
    end
  end

  def step_path
    new_trello_integration_check_path(@integration)
  end
end
