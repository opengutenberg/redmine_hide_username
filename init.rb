require Rails.root.join("plugins", "hide_user_name_by_default", "lib", "user.rb")
Redmine::Plugin.register :hide_user_name_by_default do
  name 'Hide User Name And Email and also make his/her profile private'
  author 'Redmine Romania'
  description 'Plugin for redmine that hides user name by default'
  version '0.1'
  url 'https://www.redmine.ro'
  author_url 'https://www.github.com/banica'
end
