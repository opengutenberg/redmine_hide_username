module MyUser

  def self.current_project project = nil
    @project ||= project
  end

  def self.included base
    
    base.class_eval do

      def name formatter = nil
        current_user = User.current
        project = MyUser.current_project
        roles = current_user.roles_for_project(project) if project
        other_user_r = roles_for_project(project) if project
        roles_name = roles.collect(&:name) if roles.present?
        other_user_roles = other_user_r.collect(&:name) if other_user_r.present?
        
        if ((roles and roles_name.present? and roles_name.include?('Manager'))\
              or current_user.admin? or current_user.id == self.id or (other_user_roles and other_user_roles.include?("Manager")) )
          return actual_name(formatter)
        elsif ((roles and roles_name.present? and roles_name.include?('Manager'))\
              or current_user.admin? or current_user.id == self.id or (other_user_roles and other_user_roles.include?("Manager")) )
          return actual_name(formatter)
        else
          if other_user_roles.present?
            return "(#{other_user_roles.join(', ')})"
          else
            return "Developer"
          end
        end
        return actual_name(formatter)
      end

      def mail
        current_user = User.current
        project = MyUser.current_project
        role = current_user.roles_for_project(project) if project
        if ((role and role.is_a?(Role) and [:manager].include?(role.name.downcase.to_sym))\
              or current_user.admin? or current_user.id == self.id )
          return read_attribute(:mail)
        elsif ( role and role.is_a?(Role) and \
              ([:manager].include?(role.name.downcase.to_sym))\
              or current_user.admin? or current_user.id == self.id )
          return read_attribute(:mail)
        else
          return ""
        end
        return read_attribute(:mail)
      end

      def actual_name formatter = nil
        f = self.class.name_formatter(formatter)
        if formatter
          eval('"' + f[:string] + '"')
        else
          @name ||= eval('"' + f[:string] + '"')
        end
      end

    end
    
  end
end

module MyController
  def self.included base

    base.class_eval do

      before_filter :call_me
      
      protected
      def call_me

        begin

          if params[:controller] == "users" and params[:action] == "show" and (viewing_user = User.find(params[:id]))

            current_user = User.current

            if viewing_user.id != current_user.id

              viewing_user_roles = []
              roles = []
              
              user_roles = current_user.projects_by_role
              viewing_user_roles_ = viewing_user.projects_by_role

              user_roles.each do |role|
                role.each do |r|
                  if r.is_a?(Role)
                    roles << r
                  end
                end
              end

              
              viewing_user_roles_.each do |role|
                role.each do |r|
                  if r.is_a?(Role)
                    viewing_user_roles << r
                  end
                end
              end
              
              roles_name = roles.collect(&:name) if roles
              viewing_user_roles_name = viewing_user_roles.collect(&:name) if viewing_user_roles


              if !(((roles and roles_name.present? and roles_name.include?('Manager'))\
                    or current_user.admin?) or ( viewing_user_roles_name.present? and \
                    viewing_user_roles_name.include?("Manager")
                  ))
                redirect_to :back, :alert => "You do not have access on this page!"
                return
              end
            end

          end

          if params[:id] and ( project = Project.find(params[:id]))
            MyUser.current_project(project)
          end
        rescue Exception => e
          p e
        end
      end
    end
  end
end

User.send(:include, MyUser)
ApplicationController.send(:include, MyController)