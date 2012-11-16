Installation Notes.

Overview:

"geddify" is an application designed for sending and receiving ILL (Inter-Library Loan) documents conforming to the GEDI standard.  

This (ruby on rails) application consists of two main components 
- a large utility file used to add, edit, and remove GEDI headers from files
- a set of methods used to send/receive GEDI files through ftp, http, and email

The application is designed to allow use of HTTP while also preserving compatibility with Ariel (which supports the GEDI standard).
A GEDI file, once created (or received) can be sent to patron email account, a server email account (such as an Ariel server that 
receives files through email, sent through HTTP to another geddify server, or sent through ftp to an Ariel-compatible server).  
Geddify can receive files through ftp or http.


Installation Notes:

After checking the app out from the git repo, go to the root directory and run
bundle
rake db:migrate
NOTE - the application currently requires ruby 1.9.2 or greater

Note - all configuration files come with a .sample extension.  You'll need to remove the extension.  The files themselves, which will contain IP addresses and passwords, are listed in the .gitignore file.  

To run the application, you will need to add a live IP address to 
- config/gedi.yml
- config/ftp.yml

gedi.yml contains defaults for the information that will appear in the gedi headers of the files you send from your server.
You'll need to enter the IP address for your server - unfortunately, if you're planning on integrating with FTP, you can't use localhost or 127.0.0.1 - you do need to enter the actual IP address of your machine, even if you're running this locally (you can still access the app through localhost int he browser, you just need to enter the IP address here).

ftp.yml contains the parameters the server will use to receive GEDI files through FTP.  More on this below - again, if you don't want
to use FTP at all (and you don't care about compatibility with Ariel), then feel free to skip this.
   
If you want to send email from your application, you will also need to configure

- app/mailers/gedi_mailer.rb
- config/mailer.yml
- config/initializers/setup_mailer.rb

You'll need to set up your server's email address and connection parameters.  I use google's mailer for dev, which allows 2,000 emails a day for a development mail server.  That's more than enough for dev (might even be more than enough in production depending on your use).  For more information, try the railscast tutorial at http://railscasts.com/episodes/61-sending-email.  

Ftp

Ariel uses a very specific protocol for sending and receiving documents through FTP.  Ariel will accept files from an outside server with username "document" (for ariel3) or "ariel4" and a password which is a hash of the incoming IP address.  

To achieve this, I made some modifications to the Apache Mina server.  You can run this out of the box by running (from the apache-ftpserver-1.0.5 directory)

% ./bin/ftpd.sh res/conf/ftpd-typical.xml 

You should probably change the admin password in the ftp.yml directory and the apache-ftpserver-1.0.5/res/conf/users.properties files.  These passwords need to match.

In the properties file, you'll see that users were created for "admin", "document" and "ariel4".  Definitely create a password for "admin".  Unfortunately, the modifications I made to the mina FTP server for Ariel compatibility prevent hashed passwords, so these are stored in plain text.  

You'll need to create user accounts for document and ariel4, but the passwords are meaningless.  These accounts are created for Ariel users, and any user with this name will be intercepted and authenticated through an Ariel-specific protocol.  Nobody will ever directly connect as these users with the passwords you see here.  You should change them, 
but just make them something very obscure.  

Security

Most of this application should be used only by library ILL staff or other administrators.  

The application is currently protected with a simple default filter in the application_controller.rb 
username: document
password: delivery

The application_controller.rb contains a before_filter method that will establish a username and password for all files other than the download page (which will ignore the before_filter).  This will work if all you need is a simple username and password.  Most institutions will most likely control the pages through some different authentication schema (CAS, Shibboleth, etc). 

If you intent to secure this application by filtering URLs (typical of CAS or Shib), you will want to allow patron access to http://yourserveraddress/file_download_page and http://yourserveraddress/file_download.  

If you plan to allow other geddify servers to transmit documents through http or https, you will need to allow access to the import_gedi_file method as well.  This method is excluded from the authentication filter in the rails app.  If you want to use URL control instead, you'll need to allow access to 
http://yourserveraddress/import_gedi_file

All other server paths can be restricted to staff or admin users.


Technical note regarding the Mina FTP Server

Ariel uses FTP to transfer files, using a specific connection protocol and naming schema.  To get the Mina server to accept Ariel transmissions, you need an FTP server with users "document" and "ariel4" configured accept connections with a password that is an ariel-specific hex hash of the incoming IP address. 

To accomplish this, I used the open source Apache Mina FTP server and altered the authentication method.  Note that geddify will work with any ftp server.  This is just one way to get an FTP server to accept incoming FTP transmissions.  


		/**
		* User authenticate method
		*/
		public User authenticate(Authentication authentication)
		    	throws AuthenticationFailedException {
			if (authentication instanceof UsernamePasswordAuthentication) {
		    	UsernamePasswordAuthentication upauth = (UsernamePasswordAuthentication) authentication;

		    	String user = upauth.getUsername();
		    	String password = upauth.getPassword();
			 String hexpassword = upauth.getUserMetadata().getInetAddress().getHostAddress();

		    	if (user == null) {
		        	throw new AuthenticationFailedException("Authentication failed");
		    	}

		    	if (password == null) {
		        	password = "";
		    	}

			 if (user.equals("document")) {
	 
				 try {
					 String[] hexpasswords = hexpassword.split("\\.");
			 
					 hexpassword = "";

					 for (int i=0; i<hexpasswords.length; i++) {
						 hexpassword += Integer.toHexString(Integer.parseInt(hexpasswords[i])).toUpperCase();    
					 }

					 hexpassword = hexpassword.replace("0", "#");
			 
					 System.out.println("hex password is " + hexpassword);
			 
				 } catch (Exception ex) { }
				 
			 }

		    	String storedPassword = userDataProp.getProperty(PREFIX + user
		            	+ '.' + ATTR_PASSWORD);

		    	if (storedPassword == null) {
		        	// user does not exist
		        	throw new AuthenticationFailedException("Authentication failed");
		    	}

		    	if (hexpassword.equals(password) || getPasswordEncryptor().matches(password, storedPassword)) {
		        	return getUserByName(user);
		    	} else {
		        	throw new AuthenticationFailedException("Authentication failed");
		    	}

			} else if (authentication instanceof AnonymousAuthentication) {
		    	if (doesExist("anonymous")) {
		        	return getUserByName("anonymous");
		    	} else {
		        	throw new AuthenticationFailedException("Authentication failed");
		    	}
			} else {
		    	throw new IllegalArgumentException(
		            	"Authentication not supported by this user manager");
			}
		}


Technically, you're supposed to be able to extend this and configure it, but I couldn't get that to work, so I just replaced the method and rebuilt the app.  This broke some of Mina's unit tests.  

For more information, see http://mina.apache.org/ftpserver/

Keep in mind - if you don't want to use FTP or accept transmissions from Ariel, you don't need to set up an FTP server.  Geddify can send/receive from other servers using HTTP, and can send to patrons through email.  

NOTE:

If you want to make these changes directly to the Apache Mina source, you'll need to rebuild the app.  Unfortunately, the build instructions on the Mina site didn't quite work for me.  Here's what I had to do.  

download the app (mina server)

make whatever code changes you like (in this case, replace the authenticate method with the code above), and from the root directory, run 
% mvn install

switch to the distribution directory

run

% mvn package

unzip or untar apache-ftpserver.version and copy it to distribution/common/lib

run it from 

1.0.5/target/apache-ftpserver-1.0.5

% bin/ftpd.sh res/conf/ftpd-typical.xml




















