#!powershell
# This file is part of Ansible
#
# Copyright 2015, Nicolas Landais (@nlandais) <nicolas.landais@citrix.com>
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

# WANT_JSON
# POWERSHELL_COMMON

$params = Parse-Args $args;

$result = New-Object PSObject;
Set-Attr $result "changed" $false;

#pfx_file parameter
$pfx_file = Get-AnsibleParam -obj $params -name "pfx_file" -failifempty $true -emptyattributefailmessage "Please provide the path to the pfx file as found on the target server";

#password parameter
$password = Get-AnsibleParam -obj $params -name "password" -failifempty $true -emptyattributefailmessage "Please provide the certifacte password";

#location parameter
$location = Get-AnsibleParam -obj $params -name "location" -default "CurrentUser" -ValidateSet "LocalMachine","CurrentUser";

#store_name parameter
$store_name = Get-AnsibleParam -obj $params -name "certififcate_store_name" -default "MY";

#state parameter
$state = Get-AnsibleParam -obj $params -name "State" -default "Present" -ValidateSet "present","absent";

try 
{
	#Get list of certificates in the specified store
	$store_path=Join-Path -Path cert: -ChildPath $location | Join-Path -Childpath $store_name
	$thumbprints = Get-ChildItem -Path $store_path | Foreach-Object {$_.Thumbprint}
	$pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2	
	$pfx.import($pfx_file,$password,"Exportable,PersistKeySet")	 
	$store = new-object System.Security.Cryptography.X509Certificates.X509Store($store_name,$location)	 
	$store.open("MaxAllowed")
	[bool]$certificateisinstalled = $thumbprints -contains $pfx.Thumbprint
	if (($state -eq "present") -and !($certificateisinstalled)) {
		$store.add($pfx)
		$result.changed = $true
	}
	elseif (($state -eq "absent") -and $certificateisinstalled){
		$store.remove($pfx)
		$result.changed = $true
	}
	$store.close()
    Exit-Json $result
}

catch
{
     Fail-Json $result $_.Exception.Message
}
