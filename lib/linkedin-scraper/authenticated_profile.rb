module Linkedin
  class AuthenticatedProfile < Profile
    ROOT_URL = 'https://www.linkedin.com'

    def self.get_authenticated_profile(login, password)
      begin
        Linkedin::AuthenticatedProfile.new(login, password)
      rescue => e
        puts e
      end
    end

    def initialize(login, password)
      puts http_client.user_agent

      page = http_client.get(ROOT_URL)
      page = page.form_with(name: 'login') do |form|
        form.session_key = login
        form.session_password = password
      end.submit

      page = page.links.find {|l| l.text.strip == 'Profile' }.click
      @linkedin_auth_profile_url = page.uri.to_s
      @page_auth = page

      public_profile_url = page.at('//dl[@class="public-profile"]/dd/a').attr('href')
      #public_profile_url = page.search('dl.public-profile dd a').attr('href')
      super(public_profile_url)
    end

    def connections
      conns_url = @page_auth.at('//*[@class="member-connections"]/descendant::a').attr('href')
      conns_page = http_client.get(ROOT_URL + conns_url)
      puts conns_page.at('//ol[@id="results"]')
    end
  end
end