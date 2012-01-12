#
# Cookbook Name:: notifier-setup
# Recipe:: default
#

if(node['chef-notifier'][:ssmtp])
  include_recipe 'ssmtp'
end

notifier_gem = gem_package 'chef-notifier' do
  action :nothing
  version '~> 1.0'
end
notifier_gem.run_action(:install)
Gem.clear_paths
require 'rubygems'
require 'chef-notifier/mail'

if(File.exists?('/usr/sbin/sendmail'))
  users = search(:users).find_all{|user| user['chef_notifications']}.map{|user| user[:email]}.compact
  notifier = ChefNotifier::Mailer.instance.setup(
    :recipients => users, 
    :delivery => {
      :method => :sendmail,
      :arguments => '-i'
    }
  )
  Chef::Config.exception_handlers << ChefNotifier::Mailer.instance
  Chef::Log.info "Emails added to notifications: #{users.join(', ')}"
else
  Chef::Log.warn "No emails found for notifications"
end
