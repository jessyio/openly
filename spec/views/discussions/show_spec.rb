# frozen_string_literal: true

RSpec.shared_examples 'rendering discussions/show' do
  before do
    assign(:project, project)
    assign(:discussion, discussion)
    assign(:replies, replies)
    assign(:reply, reply)
  end

  it 'renders the title of the discussion' do
    render
    expect(rendered).to have_text discussion.title
  end

  it 'renders the content of the initial reply' do
    render
    expect(rendered).to have_text discussion.initial_reply.content
  end

  it 'renders the scoped ID' do
    render
    expect(rendered).to have_text "##{discussion.scoped_id}"
  end

  it 'renders the initiator of the discussion' do
    render
    expect(rendered)
      .to have_text "#{custom_initiated_verb} by #{discussion.initiator.name}"
  end

  it 'renders the replies' do
    render
    replies.each do |reply|
      expect(rendered).to have_text reply.author.name
      expect(rendered).to have_text reply.content
    end
  end

  it 'renders a form with profile_project_discussions_replies_path action' do
    create_path =
      profile_project_discussion_replies_path(project.owner,
                                              project,
                                              discussion.type_to_url_segment,
                                              discussion)
    render
    expect(rendered).to have_css(
      'form'\
      "[action='#{create_path}']"\
      "[method='post']"
    )
  end

  it 'renders errors' do
    reply.errors.add(:base, 'mock error')
    render
    expect(rendered).to have_css '.validation-errors', text: 'mock error'
  end

  it 'has an input field for content' do
    render
    expect(rendered).to have_css('textarea#reply_content')
  end
end

RSpec.describe 'discussions/show', type: :view do
  let(:project) { discussion.project }
  let(:replies) { build_stubbed_list(:reply, 3, discussion: discussion) }
  let(:reply)   { build_stubbed(:reply, discussion: discussion) }

  context 'when @discussion is Discussions::Suggestion' do
    let(:discussion) { build_stubbed(:discussions_suggestion) }
    let(:custom_initiated_verb) { 'suggested' }
    include_examples 'rendering discussions/show'
  end

  context 'when @discussion is Discussions::Issue' do
    let(:discussion) { build_stubbed(:discussions_issue) }
    let(:custom_initiated_verb) { 'raised' }
    include_examples 'rendering discussions/show'
  end

  context 'when @discussion is Discussions::Question' do
    let(:discussion) { build_stubbed(:discussions_question) }
    let(:custom_initiated_verb) { 'asked' }
    include_examples 'rendering discussions/show'
  end
end
