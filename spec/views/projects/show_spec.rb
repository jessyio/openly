# frozen_string_literal: true

RSpec.describe 'projects/show', type: :view do
  let(:project)       { create(:project) }
  let(:root_folder)   { nil }
  let(:has_revisions) { false }
  let(:collaborators) { [] }

  before do
    assign(:project, project)
    assign(:root_folder, root_folder)
    assign(:has_revisions, has_revisions)
    assign(:collaborators, collaborators)
  end

  it 'renders the title of the project' do
    render
    expect(rendered).to have_text project.title
  end

  it 'renders the tags of the project' do
    render
    project.tags.each do |tag|
      expect(rendered).to have_css '.tag', text: view.tag_case(tag)
    end
  end

  it 'renders the description of the project' do
    render
    expect(rendered).to have_text project.description
  end

  it 'renders a link to the project home page' do
    render
    expect(rendered).to have_link(
      'Overview',
      href: profile_project_path(project.owner, project.slug)
    )
  end

  it 'does not have a link to edit the project' do
    render
    expect(rendered).not_to have_css(
      "a[href='#{edit_profile_project_path(project.owner, project)}']"
    )
  end

  it 'shows the project owner with link to their profile' do
    render
    expect(rendered).to have_link(
      project.owner.name,
      href: profile_path(project.owner)
    )
  end

  context 'when project has collaborators' do
    let(:collaborators) { build_list :user, 2 }

    it 'shows the collaborators with link to their profile' do
      render
      collaborators.each do |collaborator|
        expect(rendered).to have_link(
          collaborator.name,
          href: profile_path(collaborator)
        )
      end
    end
  end

  context 'when current user can edit project' do
    before { assign(:user_can_edit_project, true) }

    it 'does have a link to edit the project' do
      render
      expect(rendered).to have_css(
        "a[href='#{edit_profile_project_path(project.owner, project)}']"
      )
    end
  end

  context 'when a root folder exists' do
    let(:root_folder) { create :file, :root, repository: project.repository }

    it 'renders a link to the project files' do
      render
      expect(rendered).to have_link(
        'Files',
        href: profile_project_root_folder_path(project.owner, project.slug)
      )
    end

    it 'renders a link to open that folder in Google Drive' do
      render
      expect(rendered).to have_link(
        'Open in Drive',
        href: view.external_link_for_file(root_folder)
      )
    end
  end

  context 'when at least one revision exists' do
    let(:has_revisions) { true }

    it 'renders a link to the project revisions' do
      render
      expect(rendered).to have_link(
        'Revisions',
        href: profile_project_revisions_path(project.owner, project.slug)
      )
    end
  end
end
