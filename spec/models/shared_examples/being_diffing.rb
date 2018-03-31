# frozen_string_literal: true

RSpec.shared_examples 'being diffing' do
  subject { diffing }

  describe 'delegations' do
    let(:snapshot) { :current_or_previous_snapshot }

    it { is_expected.to delegate_method(:id).to(snapshot).with_prefix }
    it { is_expected.to delegate_method(:external_id).to(snapshot) }
    it { is_expected.to delegate_method(:external_link).to(snapshot) }
    it { is_expected.to delegate_method(:folder?).to(snapshot) }
    it { is_expected.to delegate_method(:icon).to(snapshot) }
    it { is_expected.to delegate_method(:mime_type).to(snapshot) }
    it { is_expected.to delegate_method(:name).to(snapshot) }
    it { is_expected.to delegate_method(:provider).to(snapshot) }
    it { is_expected.to delegate_method(:symbolic_mime_type).to(snapshot) }
    it { is_expected.to delegate_method(:thumbnail_id).to(snapshot) }
    it { is_expected.to delegate_method(:thumbnail_image).to(snapshot) }
    it do
      is_expected.to delegate_method(:thumbnail_image_or_fallback).to(snapshot)
    end

    it do
      is_expected
        .to delegate_method(:content_version)
        .to(:current_snapshot).with_prefix(:current)
    end
    it do
      is_expected
        .to delegate_method(:name)
        .to(:current_snapshot).with_prefix(:current)
    end
    it do
      is_expected
        .to delegate_method(:parent_id)
        .to(:current_snapshot).with_prefix(:current)
    end

    it do
      is_expected
        .to delegate_method(:content_version)
        .to(:previous_snapshot).with_prefix(:previous)
    end
    it do
      is_expected
        .to delegate_method(:name)
        .to(:previous_snapshot).with_prefix(:previous)
    end
    it do
      is_expected
        .to delegate_method(:parent_id)
        .to(:previous_snapshot).with_prefix(:previous)
    end
  end

  describe '#added?' do
    before do
      allow(diffing).to receive(:current_snapshot_id).and_return 123
      allow(diffing)
        .to receive(:previous_snapshot_id).and_return previous_snapshot_id
    end

    context 'when previous_snapshot_id is nil' do
      let(:previous_snapshot_id) { nil }
      it { is_expected.to be_added }
    end

    context 'when previous_snapshot_id is not nil' do
      let(:previous_snapshot_id) { 456 }
      it { is_expected.not_to be_added }
    end
  end

  describe '#ancestor_path' do
    subject { diffing.ancestor_path }
    before  do
      allow(diffing).to receive(:first_three_ancestors).and_return ancestors
    end

    context 'when first_three_ancestors = []' do
      let(:ancestors) { [] }
      it { is_expected.to eq 'Home' }
    end

    context 'when first_three_ancestors = [anc1]' do
      let(:ancestors) { %w[anc1] }
      it { is_expected.to eq 'anc1' }
    end

    context 'when first_three_ancestors = [anc1 anc2]' do
      let(:ancestors) { %w[anc1 anc2] }
      it { is_expected.to eq 'anc2 > anc1' }
    end

    context 'when first_three_ancestors = [anc1 anc2 anc3]' do
      let(:ancestors) { %w[anc1 anc2 anc3] }
      it { is_expected.to eq '.. > anc2 > anc1' }
    end
  end

  describe '#association(association_name)' do
    let(:snapshot) { instance_double FileResource::Snapshot }

    before do
      allow(diffing)
        .to receive(:current_or_previous_snapshot).and_return snapshot
    end

    after { diffing.association(association_name) }

    context 'when association name is thumbnail' do
      let(:association_name) { :thumbnail }

      it { expect(snapshot).to receive(:association).with(:thumbnail) }
    end
  end

  describe '#changed?' do
    let(:is_added)    { false }
    let(:is_deleted)  { false }
    let(:is_updated)  { false }

    before do
      allow(diffing).to receive(:added?).and_return is_added
      allow(diffing).to receive(:deleted?).and_return is_deleted
      allow(diffing).to receive(:updated?).and_return is_updated
    end

    it { is_expected.not_to be_changed }

    context 'when it is added' do
      let(:is_added)  { true }
      it              { is_expected.to be_changed }
    end

    context 'when it is deleted' do
      let(:is_deleted)  { true }
      it                { is_expected.to be_changed }
    end

    context 'when it is updated' do
      let(:is_updated)  { true }
      it                { is_expected.to be_changed }
    end
  end

  describe '#changes' do
    subject { diffing.changes }
    let(:is_added)    { false }
    let(:is_deleted)  { false }
    let(:is_modified) { false }
    let(:is_moved)    { false }
    let(:is_renamed)  { false }

    before do
      allow(diffing).to receive(:added?).and_return is_added
      allow(diffing).to receive(:deleted?).and_return is_deleted
      allow(diffing).to receive(:modified?).and_return is_modified
      allow(diffing).to receive(:moved?).and_return is_moved
      allow(diffing).to receive(:renamed?).and_return is_renamed
    end

    it { is_expected.to eq [] }

    context 'when it is added, renamed, and deleted' do
      let(:is_added)    { true }
      let(:is_renamed)  { true }
      let(:is_deleted)  { true }
      it { is_expected.to contain_exactly :added, :renamed, :deleted }
    end

    context 'when file is moved, renamed, and modified' do
      let(:is_moved)    { true }
      let(:is_renamed)  { true }
      let(:is_modified) { true }

      it 'the first change is moved' do
        expect(subject.first).to eq :moved
      end
    end

    context 'when file is renamed and modified' do
      let(:is_renamed)  { true }
      let(:is_modified) { true }

      it 'the first change is renamed' do
        expect(subject.first).to eq :renamed
      end
    end
  end

  describe '#deleted?' do
    before do
      allow(diffing).to receive(:previous_snapshot_id).and_return 123
      allow(diffing)
        .to receive(:current_snapshot_id).and_return current_snapshot_id
    end

    context 'when current_snapshot_id is nil' do
      let(:current_snapshot_id) { nil }
      it { is_expected.to be_deleted }
    end

    context 'when current_snapshot_id is not nil' do
      let(:current_snapshot_id) { 456 }
      it { is_expected.not_to be_deleted }
    end
  end

  describe 'modified?' do
    let(:current_version)   { '123' }
    let(:previous_version)  { 'abc' }
    let(:is_updated)        { true }

    before do
      allow(diffing).to receive(:updated?).and_return is_updated
      allow(diffing)
        .to receive(:current_content_version).and_return current_version
      allow(diffing)
        .to receive(:previous_content_version).and_return previous_version
    end

    it { expect(diffing).to be_modified }

    context 'when content versions are the same' do
      let(:current_version)  { 'same' }
      let(:previous_version) { 'same' }

      it { expect(diffing).not_to be_modified }
    end

    context 'when it is not updated' do
      let(:is_updated) { false }
      it { expect(diffing).not_to be_modified }
    end
  end

  describe 'moved?' do
    let(:current_parent_id)   { 51 }
    let(:previous_parent_id)  { 99 }
    let(:is_updated)          { true }

    before do
      allow(diffing).to receive(:updated?).and_return is_updated
      allow(diffing).to receive(:current_parent_id).and_return current_parent_id
      allow(diffing)
        .to receive(:previous_parent_id).and_return previous_parent_id
    end

    it { expect(diffing).to be_moved }

    context 'when parents are the same' do
      let(:current_parent_id)   { 100 }
      let(:previous_parent_id)  { 100 }

      it { expect(diffing).not_to be_moved }
    end

    context 'when it is not updated' do
      let(:is_updated) { false }
      it { expect(diffing).not_to be_moved }
    end
  end

  describe 'renamed?' do
    let(:current_name)  { 'File A' }
    let(:previous_name) { 'File B' }
    let(:is_updated)    { true }

    before do
      allow(diffing).to receive(:updated?).and_return is_updated
      allow(diffing).to receive(:current_name).and_return current_name
      allow(diffing).to receive(:previous_name).and_return previous_name
    end

    it { expect(diffing).to be_renamed }

    context 'when names are the same' do
      let(:current_name)   { 'name' }
      let(:previous_name)  { 'name' }

      it { expect(diffing).not_to be_renamed }
    end

    context 'when it is not updated' do
      let(:is_updated) { false }
      it { expect(diffing).not_to be_renamed }
    end
  end

  describe '#updated?' do
    let(:is_added)              { false }
    let(:is_deleted)            { false }
    let(:current_snapshot_id)   { 1 }
    let(:previous_snapshot_id)  { 2 }

    before do
      allow(diffing).to receive(:added?).and_return is_added
      allow(diffing).to receive(:deleted?).and_return is_deleted
      allow(diffing)
        .to receive(:current_snapshot_id).and_return current_snapshot_id
      allow(diffing)
        .to receive(:previous_snapshot_id).and_return previous_snapshot_id
    end

    it { is_expected.to be_updated }

    context 'when snapshot IDs are the same' do
      let(:current_snapshot_id)   { 13 }
      let(:previous_snapshot_id)  { 13 }
      it { is_expected.not_to be_updated }
    end

    context 'when diffing is added' do
      let(:is_added) { true }
      it { is_expected.not_to be_updated }
    end

    context 'when diffing is deleted' do
      let(:is_deleted) { true }
      it { is_expected.not_to be_updated }
    end
  end
end
