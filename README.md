# acquire-views

There are three files in the outer most directory 

ServerLog_GA_API_Report_Gen.rb 
  => This is an API report builder and Notification System 
      *Note this is an earlier draft of what is used now to automatically deploy certain campaigns; 
      
  
Social_Campaign_Email_Comp_Helper.rb 
  => This is an operations helper tool that is used to compile all campaign information and draft emails text for the team collective  
      *Note this is an earlier draft of what is now used to send emails automatically 
      
 extract_links_from_HTML_assist.rb 
  => Simple ruby script that parses all links from a give HTML creative or site 
  
  
 ALL OTHER FILES 
  => This is a basic Sinatra app that was used to compile statistics from multiples sources, stores them in a AWS DB, run various analytics against them, and present them in a front end application 


*PLEASE NOTE ALL CREDENTIALS AND SITE LOCATIONS HAVE BEEN REMOVED*
