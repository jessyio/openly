# frozen_string_literal: true

# Import a Google Drive folder and create new FolderImportJobs for any
# subfolders
class FolderImportJob < ApplicationJob
  queue_as :folder_import
  queue_with_priority 100

  def perform(*args)
    variables_from_arguments(*args)

    file = FileResources::GoogleDrive.find(file_resource_id)

    # Stage existing children of the folder
    file.children.each do |child|
      project.staged_files.create(file_resource: child)
    end

    file.pull_children

    # Schedule a new import job for any subfolders
    file.subfolders.each do |subfolder|
      schedule_folder_import_job_for(subfolder)
    end
  end

  private

  attr_accessor :file_resource_id, :project, :setup

  # Create a new FolderImportJob for the given file resource
  def schedule_folder_import_job_for(file_resource)
    FolderImportJob.perform_later(
      reference:        setup,
      file_resource_id: file_resource.id
    )
  end

  # Set instance variables from the job's arguments
  def variables_from_arguments(*args)
    reference_id          = args[0][:reference_id]
    self.setup            = Project::Setup.find(reference_id)
    self.project          = setup.project
    self.file_resource_id = args[0][:file_resource_id]
  end
end
