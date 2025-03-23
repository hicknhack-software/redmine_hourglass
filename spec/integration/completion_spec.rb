require_relative '../rails_helper'

describe 'Completion UI', type: :request do
  let(:user) do
    password = 'testing1234'
    user = create :user, password: password, password_confirmation: password

    post "/login", params: { username: user.login, password: password }
    user
  end
  let(:project) do
    project = create :project, :with_tracker
    create :member, user: user, project: project, permissions: [:hourglass_track_time, :hourglass_book_time]
    project
  end
  let(:other_project) do
    other_project = create :project, :with_tracker
    create :member, user: user, project: other_project, permissions: [:hourglass_track_time, :hourglass_book_time]
    other_project
  end
  let(:issue1) { create :issue, author: user, project: project }
  let(:issue2) { create :issue, author: user, project: other_project }
  let(:issue3) { create :issue, author: user, project: project }

  before(:each) do
    issue1
    issue2
    issue3
  end

  def as_result(issue)
    { label: "##{issue.id} #{issue.subject}",
      issue_id: issue.id.to_s,
      project_id: issue.project_id
    }
  end

  it "lists issues by name" do
    get "/hourglass/completion/issues", params: { project_id: "", term: issue1.subject } #, headers: headers
    expect(response.status).to eq 200

    data = JSON.parse(response.body, symbolize_names: true)
    expect(data).to eq [as_result(issue1)]
  end

  it "lists issues by #id" do
    get "/hourglass/completion/issues", params: { project_id: "#{project.id}", term: "##{issue2.id}" } #, headers: headers
    expect(response.status).to eq 200

    data = JSON.parse(response.body, symbolize_names: true)
    expect(data).to eq [as_result(issue2)]
  end

  it "lists issues by id" do
    get "/hourglass/completion/issues", params: { project_id: "", term: "#{issue3.id}" } #, headers: headers
    expect(response.status).to eq 200

    data = JSON.parse(response.body, symbolize_names: true)
    expect(data).to eq [as_result(issue3)]
  end
end
