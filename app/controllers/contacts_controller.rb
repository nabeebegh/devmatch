class ContactsController < ApplicationController
   def new
      @contact = Contact.new
   end
   
   def create
     @contact = Contact.new(contact_params)
     if @contact.save
        name = params[:contact][:name]
        email = params[:contact][:email]
        body = params[:contact][:comments]
        ContactMailer.contact_email(name, email, body).deliver
              # using SendGrid's Ruby Library
               # https://github.com/sendgrid/sendgrid-ruby
               require 'sendgrid-ruby'
               include SendGrid
               
               from = Email.new(email: 'test@example.com')
               to = Email.new(email: 'test@example.com')
               subject = 'Sending with SendGrid is Fun'
               content = Content.new(type: 'text/plain', value: 'and easy to do anywhere, even with Ruby')
               mail = Mail.new(from, subject, to, content)
               
               sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
               response = sg.client.mail._('send').post(request_body: mail.to_json)
               puts response.status_code
               puts response.body
               puts response.headers
        flash[:success] = "Message sent."
        redirect_to new_contact_path
     else
        flash[:danger] = @contact.errors.full_messages.join(", ")
        redirect_to new_contact_path
     end
   end
   
   private
      def contact_params
         params.require(:contact).permit(:name, :email, :comments)
      end
end