class WorldwideOrganisationPresenter < Draper::Decorator

  decorates :worldwide_organisation

  def organisation_logo_type
    OrganisationLogoType::SingleIdentity
  end

  def organisation_type
    @other_type ||= OrganisationType.find_by_name('Other')
  end
end
