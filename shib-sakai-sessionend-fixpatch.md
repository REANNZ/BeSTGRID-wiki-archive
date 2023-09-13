# Shib-sakai-sessionend-fix.patch

``` 

Index: event/event-impl/impl/src/java/org/sakaiproject/event/impl/UsageSessionServiceAdaptor.java
===================================================================
--- event/event-impl/impl/src/java/org/sakaiproject/event/impl/UsageSessionServiceAdaptor.java	(.../vendor/sakai_2-3-1)	(revision 471)
+++ event/event-impl/impl/src/java/org/sakaiproject/event/impl/UsageSessionServiceAdaptor.java	(.../trunk)	(revision 471)
@@ -1263,9 +1263,15 @@
 			// close the session on the db
 			String statement = "update SAKAI_SESSION set SESSION_END = ? where SESSION_ID = ?";
 
+			// this is ugly, but to avoid dead sessions in db we fudge end if
+			//  start and end is the same.
+			Time end = session.getEnd();
+			if(session.getEnd().getTime() - session.getStart().getTime() <= 1000)
+				end.setTime(session.getEnd().getTime() + 1000);
+
 			// collect the fields
 			Object fields[] = new Object[2];
-			fields[0] = session.getEnd();
+			fields[0] = end;
 			fields[1] = session.getId();
 
 			// process the statement

```
