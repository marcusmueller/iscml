/*
 * File: UserPreferredProjectServiceImpl.java

Purpose: Java class to get user's preferred project.
**********************************************************/

package com.wcrl.web.cml.server;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.util.HashMap;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.jobService.GetPreferredProjectService;

public class UserPreferredProjectImpl extends RemoteServiceServlet implements GetPreferredProjectService {
	
	private static final long serialVersionUID = 341533776131091670L;	
	private HashMap<Integer, String> project;
	
	public HashMap<Integer, String> getPreferredProject(int userId) 
	{
		DBConnection connection;
		try
		{
			connection = new DBConnection();
			connection.openConnection();
			Log.info("PreferredProjectResultSet Connection: " + connection);
			
			CallableStatement projectStmt = connection.getConnection().prepareCall("{ call GetPreferredProject(?) }");
			projectStmt.setInt(1, userId);
		    boolean hasProjects = projectStmt.execute();
	    	
		    System.out.println("hasProjects: " + hasProjects);
		    if(hasProjects)
		    {
		    	ResultSet projectRS = projectStmt.getResultSet();
		    	Log.info("PreferredProjectResultSet: " + projectRS);
		    	project = new HashMap<Integer, String>();
				while(projectRS.next()) 
				{    	
					project.put(projectRS.getInt("ProjectId"), projectRS.getString("ProjectName"));									
				}
				projectRS.close();        								
		    }
		    projectStmt.close();
			
			connection.closeConnection();
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}		
		return project;
	}
}