# Writing Mono applications for cluster computing

# Introduction

The Microsoft .NET framework can be used for cross platform development via the [Mono](https://reannz.atlassian.net/wiki/pages/createpage.action?spaceKey=BeSTGRID&title=Mono&linkCreation=true&fromPageId=3816950557) project, though there are some restrictions on exactly how an application ought to be developed so that it will run on the Mono platform, and so that it is suitable to be run in the Grid or Cluster environment.

# Development Environment

Mono applications can be developed and compiled with Microsoft Visual Studio, but if a license is unavailable [Mono Develop](http://monodevelop.com/) is a free open source alternative, which works on Windows, OSX, and Linux. Mono Develop works very well for C# development, but some features (e.g. intellisense code completion) are not well supported for Visual Basic.

# Console Applications

Console applications are suitable for running in the cluster computing environment. Applications should meet the following restrictions:

- All input *must* be from command line arguments, read in from files, or via network sockets (e.g. HTTP requests).
- All output *must* be directed to standard output (for .NET this is the System.Console object), or to a file. Directing output to network sockets is not recommended.
- All system notifications & error messages *must* be directed to standard error (for .NET this is the System.Console.Error object), to a logging framework, or log file.
- The application *must* run from start to finish without user interaction.
- Care *should* also be taken that exceptions are handled well, and critical errors lead to the application exiting with a non-zero value.
- Exceptions in subroutines and methods *should* pass exceptions back up to the main method.
- Exception messages *should* be sent to standard error.
- Graphic object *must not* be used, as compute nodes typically do not have GUI interfaces installed.
- Graphics *must* be rendered to file, and *must not* displayed. Rendering graphics to a network stream is not recommended.
- Applications *must* return an exit status of zero for normal operations, and *must* return a non-zero value on errors or exceptions.

**DYNAMIC LINKED LIBRARIES**

Dynamic Linked Libraries or `.dll` files are also suitable for use in cluster computing, and enable the developer to reuse their code without having to maintain separate console and GUI applications. By implementing the core algorithms of an application within a `.dll` a developer can call the objects and methods within that library by including them in another applications. For a `.dll` to be suitable for cluster computing environment, it should meet the following restrictions:
- All input *must* come from the application calling the `.dll`, this includes file handles and network streams.
- All output *must* be directed back to the application calling the `.dll`
- All system notifications & error messages *must* be directed to standard error (for .NET this is the System.Console.Error object), or back to the application to be passed to a logging framework, or log file.
- All methods within the `.dll` *must* run from start to finish without user interaction.
- Care *should* be taken that exceptions are handled well, and that docmentation recommends that an application calling the `.dll` should exit with a non-zero value on critical errors.
- Exceptions in subroutines and methods *should* pass exceptions back up to the application calling the `.dll`.
- Exception messages *should* be sent to standard error.
- Graphic object *must not* be used, as a `.dll` may be called in a non-GUI context.
- Rendered graphics *must* be handed up to the application calling the `.dll` for output to file.

# Sample Applications

# Sample C# Application

``` 

using System;

namespace SampleMonoApplication
{

	class MainClass
	{

		private static void helloworld ()
		{
			try {
				Console.WriteLine ("Hello World!");
			} catch (Exception e) {
				Console.Error.WriteLine (e.Message);
				e = new Exception ("ERROR: Exception thrown in helloworld");
				throw (e);
				// Pass exception up to Main method
			}
		}

		public static void Main (string[] args)
		{
			try {
				helloworld ();
			} catch (Exception e) {
				Console.Error.WriteLine (e.Message);
				Environment.Exit (1);
				// Exit with a non-zero value!
			}
		}
	}
}

```
