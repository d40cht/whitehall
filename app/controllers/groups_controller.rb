class GroupsController < PublicFacingController
  def show
    @organisation = Organisation.find(params[:organisation_id])
    @group = @organisation.groups.find_by_slug!(params[:id])
    @group_members = @group.members.map do |p|
      [PersonPresenter.decorate(p), RolePresenter.decorate(p.current_roles)]
    end
    set_slimmer_organisations_header([@organisation])
  end
end
