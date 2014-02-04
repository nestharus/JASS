mapname.j must be in the same directory as the map and named the same thing as the map


mapname.w3m		- everything else
mapname.j		- contains code
mapname.project	- contains registration information and stuff
resources folder
	resource1 (map-specific code etc)
	resource2 (etc)



mapname.j will automatically be created
the map will automatically include it

-- run lua script or jar (jar will then run lua script)

project is organized as follows


main project file
	install resources (will add them to mapname.j and to mapname via installation scripts)
	uninstall resources (uninstallation scripts)
	update installed resources for a map
	
main project will only install resources that are not currently installed
any resource that is included but not in the installation list will be uninstalled

all resources are inclusions except for map-specific code like settings

projects may also add directories to look for resources

if a resource is found in a different directory than the map is currently including, the directory for the map is changed


there are 2 primary scripts

compilemap
testmap