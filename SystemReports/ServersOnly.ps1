<#
	ServersOnly.ps1
	Created 11Sept2017
	Updated 07Dec2017
	By TankCR
#>

#>>Gather All Machines in Domain<<#
	##>>We would include the IPv4Address in the properties; however sometimes it causes the script to error out<<##
$ServerList = get-adcomputer -Filter{OperatingSystem -like "*Server*"} -Properties OperatingSystem,LastLogonDate,DistinguishedName|select Name, OperatingSystem, Server, LastLogonDate, Responds,IPv4address,@{n='OU';e={(($_.DistinguishedName).split(",")|select -skip 1) -join "\"}}

$date = Get-Date #>>we are string the date in case a future version of the script uses it<<#
$dateforfile = $date.ToString("ddMMMyy") #>>convert and store date to string to use for dynamic filenaming<<#

#>>Designate our server list by filtering them with the OS<<#
#>>changed the filter in line 9 making line 16 unnecessary
#$ServerList = $machines|where{$_.OperatingSystem -like "*Server*"}|select Name, OperatingSystem, Server, LastLogonDate, Responds, IPv4address, OU

#>>Set a count so we can view status of our script<<#
$count = 0

#>>Create our loop to get additional required details for our report<<#
FOREACH($server in $ServerList)
{
	$count++ #>>Add one to the count<<#
	#>>Write our status bar<<#
	Write-Progress -Activity "Gathering additional Server Details" -Status "$($count / $ServerList.Count * 100)% complete ($($count) of $($ServerList.count))" -CurrentOperation "processing Server '$($Server.Name)'" -PercentComplete $($count / $ServerList.Count * 100)
	$Server.Server = "True" #>>Set Server Field to True<<#
	#>>Get network info<<#
	$network = Test-Connection -ComputerName $server.name -Count 1 -ErrorAction SilentlyContinue
		##>>Check and write if good connection<<##
		IF($network.IPV4Address -eq $null){$server.Responds = "Disonnected"}Else{$server.Responds = "Responds"
			$server.IPv4Address = $network.IPV4Address}
		##>>Discard Network info<<##
		$network = $null 
}
#>>Export our Server Report with timestamp<<##
$Serverlist|export-csv C:\belltech\$dateforfile-ServerReport.csv -NoTypeInformation

