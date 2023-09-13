# Shib-sakai-su-shibb.patch

``` 

Index: user/user-impl/impl/project.xml
===================================================================
--- user/user-impl/impl/project.xml	(.../vendor/sakai_2-3-1)	(revision 466)
+++ user/user-impl/impl/project.xml	(.../trunk)	(revision 466)
@@ -105,6 +105,12 @@
 		</dependency>
 
 		<dependency>
+			<groupId>sakaiproject</groupId>
+			<artifactId>sakai-tool-servlet</artifactId>
+			<version>${sakai.version}</version>
+		</dependency>
+
+		<dependency>
 			<groupId>commons-logging</groupId>
 			<artifactId>commons-logging</artifactId>
 			<version>1.0.4</version>
@@ -122,6 +128,12 @@
 			<version>1.0.2</version>
 		</dependency>
 
+		<dependency>
+			<groupId>servletapi</groupId>
+			<artifactId>servletapi</artifactId>
+			<version>2.4</version>
+		</dependency>
+
 	</dependencies>
 
 	<build>
Index: user/user-impl/impl/src/java/org/sakaiproject/user/impl/PromiscousDbUserService.java
===================================================================
--- user/user-impl/impl/src/java/org/sakaiproject/user/impl/PromiscousDbUserService.java	(.../vendor/sakai_2-3-1)	(revision 0)
+++ user/user-impl/impl/src/java/org/sakaiproject/user/impl/PromiscousDbUserService.java	(.../trunk)	(revision 466)
@@ -0,0 +1,88 @@
+/**********************************************************************************
+ * $Url$
+ * $Id$
+ ***********************************************************************************
+ *
+ * Copyright (c) 2003, 2004, 2005, 2006 The Sakai Foundation.
+ * 
+ * Licensed under the Educational Community License, Version 1.0 (the "License"); 
+ * you may not use this file except in compliance with the License. 
+ * You may obtain a copy of the License at
+ * 
+ *      http://www.opensource.org/licenses/ecl1.php
+ * 
+ * Unless required by applicable law or agreed to in writing, software 
+ * distributed under the License is distributed on an "AS IS" BASIS, 
+ * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
+ * See the License for the specific language governing permissions and 
+ * limitations under the License.
+ *
+ **********************************************************************************/
+
+package org.sakaiproject.user.impl;
+
+import javax.servlet.http.HttpServletRequest;
+
+import org.apache.commons.logging.Log;
+import org.apache.commons.logging.LogFactory;
+import org.sakaiproject.event.api.EventTrackingService;
+import org.sakaiproject.user.api.User;
+import org.sakaiproject.user.api.UserEdit;
+import org.sakaiproject.user.api.UserNotDefinedException;
+import org.sakaiproject.util.RequestFilter;
+
+/*
+	PromiscousDbUserService is a very promiscous userservice allocating uuids
+	for all uids asked for.
+   */
+public abstract class PromiscousDbUserService extends DbUserService
+{
+	/** Our log (commons). */
+	private static Log M_log = LogFactory.getLog(PromiscousDbUserService.class);
+
+	public void init()
+	{
+		super.init();
+	}
+
+	public void destroy()
+	{
+		super.destroy();
+	}
+
+	/**
+	 * {@inheritDoc}
+	 */
+	public String getUserId(String eid) throws UserNotDefinedException
+	{
+		eid = cleanEid(eid);
+
+		// first, check our map
+		String id = m_storage.checkMapForId(eid);
+		if (id != null) return id;
+
+		// if we're looking for a user that doesn't exist and isn't the current user just add it.
+		HttpServletRequest request = (HttpServletRequest)threadLocalManager().get(RequestFilter.CURRENT_HTTP_REQUEST);
+		if(request.getRemoteUser() != eid)
+		{
+			// allocate the id to use if this succeeds
+			id = assureUuid(null, eid);
+
+			try
+			{
+				UserEdit user = addUser(id, eid);
+				commitEdit(user);
+			}
+			catch (Exception e)
+			{
+				// not very pretty, but let's throw it again as not defined..
+				e.printStackTrace();
+				throw new IllegalArgumentException(e);
+			}
+			M_log.debug(eid + " was added as " + id);
+			return id;
+		}
+
+		throw new UserNotDefinedException(eid);
+	}
+}
Index: user/user-impl/pack/src/webapp/WEB-INF/components.xml
===================================================================
--- user/user-impl/pack/src/webapp/WEB-INF/components.xml	(.../vendor/sakai_2-3-1)	(revision 466)
+++ user/user-impl/pack/src/webapp/WEB-INF/components.xml	(.../trunk)	(revision 466)
@@ -4,7 +4,7 @@
 <beans>
 
 	<bean id="org.sakaiproject.user.api.UserDirectoryService"
-			class="org.sakaiproject.user.impl.DbUserService"
+			class="org.sakaiproject.user.impl.PromiscousDbUserService"
 			init-method="init"
 			destroy-method="destroy"
 			singleton="true">
Index: login/login-tool/tool/project.xml
===================================================================
--- login/login-tool/tool/project.xml	(.../vendor/sakai_2-3-1)	(revision 466)
+++ login/login-tool/tool/project.xml	(.../trunk)	(revision 466)
@@ -31,6 +31,15 @@
 			<artifactId>sakai-tool-api</artifactId>
 			<version>${sakai.version}</version>
 		</dependency>
+          
+                <dependency>
+                        <groupId>sakaiproject</groupId>
+                        <artifactId>sakai-entity-api</artifactId>
+                        <version>${sakai.version}</version>
+                        <properties>
+                                <war.bundle>true</war.bundle>
+                        </properties> 
+                </dependency>
 
 		<dependency>
 			<groupId>sakaiproject</groupId>
Index: login/login-tool/tool/src/java/org/sakaiproject/login/tool/ShibContainerLogin.java
===================================================================
--- login/login-tool/tool/src/java/org/sakaiproject/login/tool/ShibContainerLogin.java	(.../vendor/sakai_2-3-1)	(revision 0)
+++ login/login-tool/tool/src/java/org/sakaiproject/login/tool/ShibContainerLogin.java	(.../trunk)	(revision 466)
@@ -0,0 +1,308 @@
+/*
+ * Created on Mar 14, 2007
+ *
+ */
+package org.sakaiproject.login.tool;
+
+import java.io.IOException;
+import java.util.ArrayList;
+import java.util.Collection;
+import java.util.List;
+import javax.servlet.ServletException;
+import javax.servlet.http.HttpServletRequest;
+import javax.servlet.http.HttpServletResponse;
+
+import org.sakaiproject.component.cover.ServerConfigurationService;
+import org.sakaiproject.event.cover.UsageSessionService;
+import org.sakaiproject.tool.api.Session;
+import org.sakaiproject.tool.cover.SessionManager;
+import org.sakaiproject.user.api.User;
+import org.sakaiproject.user.api.UserDirectoryService;
+import org.sakaiproject.user.api.UserEdit;
+import org.sakaiproject.user.api.UserNotDefinedException;
+import org.sakaiproject.util.StringUtil;
+
+public class ShibContainerLogin extends ContainerLogin {
+
+	private String[] scopes;
+	private String affiliationHeader;
+	private String m_mailHeader;
+	private String m_givenNameHeader;
+	private String m_surnameHeader;
+	private String m_mailAliasHeader;
+	private String noUserRedirectUrl = ServerConfigurationService.getString("shib.nouser.redirect.url");
+	
+	@Override
+	public void init() throws ServletException {		
+		affiliationHeader = "Shib-EP-Affiliation";
+		m_mailHeader = "Shib-InetOrgPerson-mail";
+		m_givenNameHeader = "Shib-InetOrgPerson-givenName";
+		m_surnameHeader = "Shib-Person-surname";
+		m_mailAliasHeader = "Shib-InetLocalMailRecipient-mailLocalAddress";
+		scopes = new String[] { "su.se" };
+	}
+	
+	private class UserInfo {
+		private String eid;
+		private String firstName;
+		private String lastName;
+		private String[] email;
+		private String[] alias;
+		private String type;
+		
+		public String getEid() {
+			return eid;
+		}
+		
+		public void setEid(String eid) {
+			this.eid = eid;
+		}
+		
+		public String[] getEmail() {
+			return email;
+		}
+		
+		public void setEmail(String[] email) {
+			this.email = email;
+		}
+		
+		public String[] getAlias() {
+			return alias;
+		}
+		
+		public void setAlias(String[] alias) {
+			this.alias = alias;
+		}
+		
+		public String getFirstName() {
+			return firstName;
+		}
+		
+		public void setFirstName(String firstName) {
+			this.firstName = firstName;
+		}
+		
+		public String getLastName() {
+			return lastName;
+		}
+		
+		public void setLastName(String lastName) {
+			this.lastName = lastName;
+		}
+		
+		public String getType() {
+			return type;
+		}
+		
+		public void setType(String type) {
+			this.type = type;
+		}
+		
+		public UserInfo() {
+			
+		}
+		
+		public String toString() {
+			return "UserInfo["+firstName+" "+lastName+" "+type+" "+email[0]+"]";
+		}
+	
+		private String scopeOf(String principal)
+		{
+			int atIdx = principal.indexOf('@');
+			if (atIdx == -1)
+				return null;
+			
+			return principal.substring(atIdx+1);
+		}
+		
+		private String scopedLocalPart(String str, String scope)
+		{
+			int atIdx = str.indexOf('@');
+			if (atIdx == -1)
+				return null;
+			
+			String theScope = str.substring(atIdx+1);
+			
+			return theScope.equalsIgnoreCase(scope) ? str.substring(0,atIdx) : null;
+		}
+		
+		private String[] affiliationsOf(HttpServletRequest req, String scope)
+		{
+			List<String> affiliations = new ArrayList<String>();
+			String scopedAffiliationHeader = req.getHeader(affiliationHeader);
+			if (scopedAffiliationHeader != null && scopedAffiliationHeader.length() > 0)
+			{
+				String[] scopedAffiliations = StringUtil.split(scopedAffiliationHeader, ";");
+				for (int i = 0; i < scopedAffiliations.length; i++)
+				{
+					String affiliation = scopedLocalPart(scopedAffiliations[i], scope);
+					if (affiliation != null)
+						affiliations.add(affiliation);
+				}
+			}
+			
+			return affiliations.toArray(new String[affiliations.size()]);
+		}
+		
+		private boolean isInArray(String v, String[] values)
+		{
+			if (values == null || v == null)
+				return false;
+			
+			for (int i = 0; i < values.length; i++)
+			{
+				if (values[i].equalsIgnoreCase(v))
+					return true;
+			}
+			
+			return false;
+		}
+		
+		private boolean inScope(String scope)
+		{
+			return isInArray(scope,scopes);
+		}
+		
+		public UserInfo(String eid) {
+			setEid(eid);
+		}
+		
+		public UserInfo(HttpServletRequest req, String eid) 
+		{
+			this(eid);
+			
+			String mailHeader = req.getHeader(m_mailHeader);
+			System.err.println("mail: "+mailHeader);
+			String[] email = mailHeader == null ? null : mailHeader.split(";");
+			setEmail(email);
+			
+			String mailAliasHeader = req.getHeader(m_mailAliasHeader);
+			System.err.println("alias: "+mailHeader);
+			String[] alias = mailAliasHeader == null ? null : mailAliasHeader.split(";");
+			setAlias(alias);
+			
+			String givenNameHeader = req.getHeader(m_givenNameHeader);
+			setFirstName(givenNameHeader);
+
+			String surnameHeader = req.getHeader(m_surnameHeader);
+			setLastName(surnameHeader);
+	
+			String type = "guest";
+			String scope = scopeOf(eid);
+			if (scope != null && inScope(scope))
+			{
+				type = "registered";
+		
+				String[] affiliations = affiliationsOf(req, scope);
+				if (isInArray("member",affiliations) || isInArray("employee",affiliations))
+					type = "maintain";
+			}
+
+			setType(type);
+			
+			System.err.println(this);
+		}
+	}
+	
+	protected void runAs(User runAsUser, HttpServletRequest req, Runnable block)
+	{
+		Session currentSession = SessionManager.getCurrentSession();
+		Session adminSession = null;
+		try {
+			adminSession = SessionManager.startSession();
+			SessionManager.setCurrentSession(adminSession);
+			UsageSessionService.login(new org.sakaiproject.util.Authentication(runAsUser.getId(),runAsUser.getEid()), req);
+			
+			block.run();
+			
+		} catch (Throwable t) {
+			t.printStackTrace();
+		}
+		
+		UsageSessionService.logout();
+		if (adminSession != null)
+			adminSession.invalidate();
+		SessionManager.setCurrentSession(currentSession);
+	}
+	
+	@Override
+	protected void doGet(final HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
+		
+		final UserDirectoryService uds = org.sakaiproject.user.cover.UserDirectoryService.getInstance();
+		final String eid = req.getUserPrincipal() == null ? null : req.getUserPrincipal().getName();
+		if (eid == null || eid.equals(""))
+		{
+			res.sendRedirect(noUserRedirectUrl);
+			return;
+		}
+		
+		User adminUser = null;
+		try {
+			adminUser = uds.getUserByEid("admin");
+		} catch (UserNotDefinedException ex) {
+			throw new ServletException("No admin user");
+		}
+		
+		runAs(adminUser,req,new Runnable() {
+			public void run() {
+				try {
+					UserInfo info = new UserInfo(req,eid);
+					User user = null;
+					try {
+						user = uds.getUserByEid(eid);
+					} catch (UserNotDefinedException ex) {
+						user = null;
+					}
+					
+					String[] mail = info.getEmail();
+					if (mail != null)
+					{
+						for (int i = 0; i < mail.length && user == null; i++)
+						{
+							Collection users = uds.findUsersByEmail(mail[i]);
+							if (users.size() == 1)
+								user = (User)users.iterator().next();
+						}
+					}
+					
+					String[] alias = info.getAlias();
+					if (alias != null)
+					{
+						for (int i = 0; i < alias.length && user == null; i++)
+						{
+							Collection users = uds.findUsersByEmail(alias[i]);
+							if (users.size() == 1)
+								user = (User)users.iterator().next();
+						}
+					}
+					
+					if (user != null) {
+						UserEdit edit = uds.editUser(user.getId());
+						edit.setEmail(mail[0]);
+						edit.setFirstName(info.getFirstName());
+						edit.setLastName(info.getLastName());
+						edit.setType(info.getType());
+						uds.commitEdit(edit);	
+					} 
+					else
+					{
+						uds.addUser(null, 
+								eid, 
+								info.getFirstName(), 
+								info.getLastName(), 
+								mail[0],
+								null, 
+								info.getType(), 
+								null);
+					}
+					
+				} catch (Exception ex) {
+					ex.printStackTrace();
+				}
+			}});
+		
+		
+		super.doGet(req, res);
+	}
+	
+}
Index: login/login-tool/tool/src/webapp/WEB-INF/web.xml
===================================================================
--- login/login-tool/tool/src/webapp/WEB-INF/web.xml	(.../vendor/sakai_2-3-1)	(revision 466)
+++ login/login-tool/tool/src/webapp/WEB-INF/web.xml	(.../trunk)	(revision 466)
@@ -49,7 +49,7 @@
 
     <servlet>
         <servlet-name>sakai.login.container</servlet-name>
-        <servlet-class>org.sakaiproject.login.tool.ContainerLogin</servlet-class>
+        <servlet-class>org.sakaiproject.login.tool.ShibContainerLogin</servlet-class>
         <load-on-startup>1</load-on-startup>
     </servlet>
 


```
