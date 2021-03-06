THE_DOCUMENT = Transform(/the (document|publication|policy|news article|consultation|consultation response|speech|worldwide priority|detailed guide|announcement|world location news article|statistical data set) "([^"]*)"/) do |document_type, title|
  document_class(document_type).latest_edition.find_by_title!(title)
end

module DocumentHelper
  def document_class(type)
    type = 'edition' if type == 'document'
    type.gsub(" ", "_").classify.constantize
  end

  def set_lead_organisation_on_document(organisation, order = 1)
    if has_css?("select#edition_lead_organisation_ids_#{order}")
      select organisation.name, from: "edition_lead_organisation_ids_#{order}"
    end
  end

  def begin_drafting_document(options)
    if Organisation.count == 0
      create(:organisation)
    end
    visit admin_editions_path
    click_link "Create #{options[:type].titleize}"
    fill_in "Title", with: options[:title]
    fill_in "Body", with: options[:body] || "Any old iron"
    fill_in "Summary", with: options[:summary] || 'one plus one euals two!'
    fill_in_change_note_if_required
    set_lead_organisation_on_document(Organisation.first)
    if options[:alternative_format_provider]
      select options[:alternative_format_provider].name, from: "edition_alternative_format_provider_id"
    end
    if options[:primary_mainstream_category]
      select options[:primary_mainstream_category].title, from: "Primary detailed guidance category"
    end
  end

  def begin_drafting_policy(options)
    begin_drafting_document(options.merge(type: "policy", summary: options[:summary] || "Policy summary", alternative_format_provider: create(:alternative_format_provider)))
  end

  def begin_editing_document(title)
    visit_document_preview title
    click_link "Edit"
  end

  def begin_new_draft_document(title)
    visit_document_preview title
    click_button "Create new edition"
  end

  def begin_drafting_news_article(options)
    begin_drafting_document(options.merge(type: "news_article"))
    fill_in_news_article_fields
  end

  def begin_drafting_consultation(options)
    begin_drafting_document(options.merge(type: "consultation"))
    select_date "Opening Date", with: 10.days.from_now.to_s
    select_date "Closing Date", with: 40.days.from_now.to_s
  end

  def begin_drafting_world_location_news_article(options)
    begin_drafting_document(options.merge(type: "world_location_news_article"))
  end

  def begin_drafting_publication(title)
    policy = create(:policy)
    begin_drafting_document type: 'publication', title: title, summary: "Some summary of the content", alternative_format_provider: create(:alternative_format_provider)
    fill_in_publication_fields
    select policy.title, from: "Related policies"
  end

  def begin_drafting_statistical_data_set(title)
    begin_drafting_document type: 'statistical_data_set', title: title, summary: "Some summary of the content"
  end

  def begin_drafting_speech(options)
    organisation = create(:ministerial_department)
    person = create_person("Colonel Mustard")
    role = create(:ministerial_role, name: "Attorney General", organisations: [organisation])
    role_appointment = create(:role_appointment, person: person, role: role, started_at: Date.parse('2010-01-01'))
    speech_type = SpeechType::Transcript
    begin_drafting_document options.merge(type: 'speech', summary: "Some summary of the content")
    select speech_type.name, from: "Type"
    select "Colonel Mustard, Attorney General", from: "Speaker"
    select_date "Delivered on", with: 1.day.ago.to_s
    fill_in "Location", with: "The Drawing Room"
  end

  def new_attachments_zip_file
    Rails.root.join('test/fixtures/two-pages-and-greenpaper.zip')
  end

  def pdf_attachment
    Rails.root.join('features/fixtures/attachment.pdf')
  end

  def fill_in_news_article_fields
    select "News story", from: "News article type"
  end

  def fill_in_publication_fields
    select_date "Publication date", with: "2010-01-01"
    select "Research and analysis", from: "Publication type"
  end

  def visit_document_preview(title, scope = :scoped)
    document = Edition.send(scope).find_by_title(title)
    visit admin_edition_path(document)
  end

  def fill_in_change_note_if_required
    if has_css?("textarea[name='edition[change_note]']")
      fill_in "edition_change_note", with: "changes"
    end
  end

  def refute_flash_alerts_exist
    refute has_css?(".flash.alert")
  end

  def publish(options = {})
    click_button options[:force] ? "Force Publish" : "Publish"
    unless options[:ignore_errors]
      refute_flash_alerts_exist
    end
  end

  def add_attachment(title, filename, section)
    within section do
      if page.has_field?("Individual upload")
        choose "Individual upload"
      end
      fill_in "Title", with: title
      attach_file "File", Rails.root.join("features/fixtures", filename)
    end
  end

  def speed_tag_publication(title)
    edition = Edition.find_by_title(title)
    visit admin_edition_path(edition)

    assert page.has_css?('.speed-tag')
    within '.speed-tag' do
      select 'Research and analysis', from: 'Publication type'
      click_on 'Save'
      assert page.has_no_css?('.speed-tag .alert')
    end
  end

  def convert_to_draft(title)
    edition = Edition.find_by_title(title)
    visit admin_edition_path(edition)

    click_on 'Convert to draft'
    assert page.has_no_css?('.speed-tag')
  end
end

World(DocumentHelper)
