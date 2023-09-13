# ShARPE crosswork configuration patch

;Copy and save the following patch file as ShARPE_0.7.3_patch.txt

``` 

--- build.xml	2007-03-30 10:59:38.000000000 +1200
+++ ../build.xml	2007-08-21 16:36:59.000000000 +1200
@@ -10,7 +10,8 @@
     <property name="sharpe.metainf" value="${temp.metainf}/sharpe-metainf"/>
     <property name="autograph.metainf" value="${temp.metainf}/autograph-metainf"/>
     <property name="spdescription.metainf" value="${temp.metainf}/spde-metainf"/>
-
+    <property name="extension.name.crosswalk" value="mams-core-crosswalk"/>
+    <property name="extension.name.spdescription" value="mams-spdescription"/>
     <!-- antcontrib tasks -->
     <taskdef resource="net/sf/antcontrib/antcontrib.properties" classpath="${sharpe.lib}/ant-contrib.jar"/>
 
@@ -426,6 +427,9 @@
             <param name="spdescription.webapp.name" value="${spdescription.webapp.name}"/>
         </antcall>
       
+	 <antcall target="-replace-shib-custome-IDP_HOME"/>
+	<antcall target="-replace-shib-custome-extensions"/>
+
         <antcall target="-package">
             <param name="ignore.call.shib.package" value="true"/>
         </antcall>
@@ -740,4 +744,22 @@
         <sharpegen input="${sharpe.token.value.input}" addproperty="sharpe.token.value.output"/>
         <!--        <var name="sharpe.token.value" value="${sharpe.token.value.output}" /> -->
     </target>
+
+    <target name="-replace-shib-custome-IDP_HOME" unless="IDP_HOME-replaced" depends="-load-shib-properties">
+	<echo>Replacing $IDP_HOME$/ variable with ${idp.home.url} in ${shib.custom}</echo>
+	<replace dir="${shib.custom}" token="$IDP_HOME$/" value="${idp.home.url}" />
+	<var name="IDP_HOME-replaced" value="true"/>
+    </target>
+	
+    <target name="-replace-shib-custome-extensions" unless="Extensions-replaced" depends="-load-shib-properties">
+        <echo>Replacing $EXTENSION_NAME$ variable with ${extension.name.crosswalk} in ${shib.custom}/${extension.name.crosswalk}</echo>
+        <replace dir="${shib.custom}/${extension.name.crosswalk}" token="$EXTENSION_NAME$" value="${extension.name.crosswalk}" />
+	<echo>Replacing $EXTENSION_NAME$ variable with ${extension.name.crosswalk} in ${shib.custom}/mams-websharpe</echo>
+        <replace dir="${shib.custom}/mams-websharpe" token="$EXTENSION_NAME$" value="${extension.name.crosswalk}" />
+	<echo>Replacing $EXTENSION_NAME$ variable with ${extension.name.crosswalk} in ${shib.custom}/web/ShARPE</echo>
+        <replace dir="${shib.custom}/web/ShARPE" token="$EXTENSION_NAME$" value="${extension.name.crosswalk}" />
+        <echo>Replacing $EXTENSION_NAME$ variable with ${extension.name.spdescription} in ${shib.custom}/${extension.name.spdescription}</echo>
+        <replace dir="${shib.custom}/${extension.name.spdescription}" token="$EXTENSION_NAME$" value="${extension.name.spdescription}" />
+	<var name="Extensions-replaced" value="true"/>	
+    </target>
 </project>
--- custom/mams-spdescription/src-conf/spdescriptionconfig.properties   2007-03-30 10:58:00.000000000 +1200
+++ ../spdescriptionconfig.properties   2007-08-21 15:50:58.000000000 +1200
@@ -1,5 +1,5 @@

 #temp folder is currently not used in sp description, refer to StoreSPAction
-TempFolder=file://$IDP_HOME$/etc/$EXTENSION_NAME$/temp
+TempFolder=$IDP_HOME$/etc/$EXTENSION_NAME$/temp

-ServiceConfigFile=file://$IDP_HOME$/etc/$EXTENSION_NAME$/services.xml
\ No newline at end of file
+ServiceConfigFile=$IDP_HOME$/etc/$EXTENSION_NAME$/services.xml


```
