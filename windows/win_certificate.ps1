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
Set-Attr $result "certhash";

#pfx_file parameter
$pfx_file = Get-AnsibleParam -obj $params -name "pfx_file" -failifempty $true -emptyattributefailmessage "Please provide the path to the pfx file as found on the target server";

#password parameter
$password = Get-AnsibleParam -obj $params -name "password" -failifempty $true -emptyattributefailmessage "Please provide the certifacte password";

#location parameter
$location = Get-AnsibleParam -obj $params -name "location" -default "CurrentUser" -ValidateSet "LocalMachine","CurrentUser";

#store_name parameter
$store_name = Get-AnsibleParam -obj $params -name "certificate_store_name" -default "MY";

#state parameter
$state = Get-AnsibleParam -obj $params -name "State" -default "present" -ValidateSet "present","absent";

try 
{
	#Get list of certificates in the specified store
	$store_path=Join-Path -Path cert: -ChildPath $location | Join-Path -Childpath $store_name
	$pfx_location = "Cert:\$location\$store_name" 
	Set-Location $pfx_location
	$thumbprints = Get-ChildItem | Foreach-Object {$_.Thumbprint}

	$pfx_password = ConvertTo-SecureString -String $password -Force -AsPlainText
	
	$pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2
	$pfx.import($pfx_file,$password,"Exportable,PersistKeySet")	
	$result.certhash = $pfx.Thumbprint

	[bool]$certificateisinstalled = $thumbprints -contains $pfx.Thumbprint
	if (($state -eq "present") -and !($certificateisinstalled)) {
		Import-PfxCertificate -FilePath $pfx_file -CertStoreLocation $pfx_location -Exportable -Password $pfx_password
		$result.changed = $true
	}
	elseif (($state -eq "absent") -and $certificateisinstalled){
		$store = new-object System.Security.Cryptography.X509Certificates.X509Store($store_name,$location)	 
		$store.open("MaxAllowed")
		$store.remove($pfx)
		$result.changed = $true
		$store.close()
	}

    Exit-Json $result
}

catch
{
     Fail-Json $result $_.Exception.Message
}
