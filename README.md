# blackducktools
## get_components.sh

Script to search the Black Duck KB for components matching string

Description:

 	Returns a list of OSS components from the KB matching the supplied string

 Arguments:
 
	string	- Search for components matching "string" (required)

## get_policy_violators.sh

Script to create a list of project/versions which violate policies

Description:

  Extracts a list of all policies (or a subset specified by search string)
  Reports which policies are violated within all versions within all projects (up to 1000)
  Will write list of policy violated, project name, version name and URL to policies_versions.csv
  If output file policies_versions.csv exists will terminate unless -f option is specified

Arguments:

  -f		-	Remove existing output file policies_versions.csv (optional)
  string	-	Search for policies with name matching "string" only (optional)
