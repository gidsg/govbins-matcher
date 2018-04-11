require 'register_client_manager'
require 'octokit'
class IndexController < ApplicationController
  def show
    Octokit::Client.new(
      client_id:  ENV['GITHUB_CLIENT_ID'],
      client_secret: ENV['GITHUB_CLIENT_SECRET']
    )
    contents = Octokit.contents('HarryTrimble/govbins.uk', path: 'images')
    image_paths = contents.select { |e| e.download_url.to_s.end_with? '.jpg' }.map(&:download_url)
    @image_path_matched_to_name = image_paths.map { |ip|
      { name: ip.end_with?('St-Helens.jpg') ? 'St. Helens' :  ip.split('/images/')[1].split('.')[0].tr('-', ' '), path: ip }
    }

    registers_client = RegistersClient::RegisterClientManager.new
    local_authorities = ['local-authority-eng', 'local-authority-nir', 'local-authority-sct', 'principal-local-authority']
    local_authorities.each do |local_authority|
      instance_variable_set("@#{local_authority.underscore}".to_sym, registers_client.get_register(local_authority, 'beta'))
    end
    @local_authority_registers = [@local_authority_eng, @local_authority_nir, @local_authority_sct, @principal_local_authority]
    render :show
  end
end
