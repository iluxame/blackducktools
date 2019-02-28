# blackducktools
## get_components.sh

Script to search the Black Duck KB for components matching string. 

### Description:

Returns a list of OSS components from the KB matching the supplied string

### Prerequisites & configuration:

* Requires jq to be installed.
* Modify the script to add a valid API key and the Server URL.

### Arguments:
 
* string	- Search for components starting with "string" (required)

### Example execution:

`./get_component.sh spring`

Will produce output:

    Searching for component 'spring'
    Getting Auth Token ...
    Getting list of matching components ...
    Found the following components:
    "Spring Boot"
    "Spring Framework"
    "Spring RTS Engine"
    "Spring Web Flow"
    "Spring LDAP"
    "Spring Data JPA"
    "Spring Data MongoDB"
    "Spring Security SAML"
    "Spring roo"
    "Spring Integration"


## get_policy_violators.sh

Script to create a list of project/versions which violate policies

### Description:

Extracts a list of all policies (or a subset specified by search string)
Reports which policies are violated within all versions within all projects (up to 1000)
Will write list of policy violated, project name, version name and URL to policies_versions.csv
If output file policies_versions.csv exists will terminate unless -f option is specified

### Prerequisites & configuration:

* Requires jq to be installed.
* Modify the script to add a valid API key and the Server URL.

### Arguments:

* -f		-	Remove existing output file policies_versions.csv (optional)
* string	-	Search for policies with name matching "string" only (optional)

### Example execution:

`./get_policy_violators.sh`

Will produce output:

```
Getting Auth Token from https://hubtesting.blackducksoftware.com ...
18 Policies Returned
Processing Project "1"
    Processing Version "1"
Processing Project "2"
    Processing Version "2"
Processing Project "7-Zip"
    Processing Version "1"
    Processing Version "9.20"
Processing Project "<PROJECT"
    Processing Version "Default Detect Version"
Processing Project "accs-availability-srvc"
    Processing Version "1.0.0-SNAPSHOT"
Processing Project "accs-common"
    Processing Version "1.0.0-SNAPSHOT"
Processing Project "accs-template-service"
    Processing Version "1.0.19"
Processing Project "AdamKernelLTE"
    Processing Version "1.0"
Processing Project "AdamLTESnippet"
    Processing Version "1.0"
Processing Project "AISA Information"
    Processing Version "1"
Processing Project "ali bd"
    Processing Version "1"
Processing Project "ali bd struts"
    Processing Version "1"
Processing Project "Ali Binary"
    Processing Version "1"
    Processing Version "2"
    Processing Version "3"
...
```

Output file (policies_versions.csv):

```
"Global Whitelist","1","1","https://hubtesting.blackducksoftware.com/api/projects/bcdec5cc-aeb7-4f6d-85ff-31a38e8e688c/versions/0d225c71-b635-460a-b91b-af5810fd3dca"
"Global Whitelist","2","2","https://hubtesting.blackducksoftware.com/api/projects/75b1e45d-2e9a-4d72-a2d0-af43d4bc10a9/versions/a65c9af6-ba48-48de-8134-a98611815e09"
"No High Vulnerability","2","2","https://hubtesting.blackducksoftware.com/api/projects/75b1e45d-2e9a-4d72-a2d0-af43d4bc10a9/versions/a65c9af6-ba48-48de-8134-a98611815e09"
"Global Whitelist","7-Zip","1","https://hubtesting.blackducksoftware.com/api/projects/83a8766a-bae1-48d3-adb3-f28145ca5cb4/versions/a930be65-4572-4ee7-8006-cc2b4e3565a0"
"Global Whitelist","7-Zip","9.20","https://hubtesting.blackducksoftware.com/api/projects/83a8766a-bae1-48d3-adb3-f28145ca5cb4/versions/09ed0748-fb56-412c-966a-ac760aef180a"
"Global Whitelist","accs-availability-srvc","1.0.0-SNAPSHOT","https://hubtesting.blackducksoftware.com/api/projects/99b6e506-a489-4410-8e40-a2b97e49d485/versions/399c863c-e6e4-4195-920a-c2c0092063f2"
```

