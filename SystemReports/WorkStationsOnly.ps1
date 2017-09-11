<#
	WorkStationsOnly.ps1
	Created 11Sept2017
	By TankCR
#>

#>>Gather All Machines in Domain<<#
	##>>We would include the IPv4Address in the properties; however sometimes it causes the script to error out<<##
$machines = get-adcomputer -Filter * -Properties OperatingSystem,LastLogonDate,DistinguishedName|select Name, OperatingSystem, Server, LastLogonDate, Responds,IPv4address,@{n='OU';e={(($_.DistinguishedName).split(",")|select -skip 1) -join "\"}}

$date = Get-Date #>>we are string the date in case a future version of the script uses it<<#
$dateforfile = $date.ToString("ddMMMyy") #>>convert and store date to string to use for dynamic filenaming<<#

#>>Designate our workstation list by filtering them with the OS<<#
$WorkstationList = $machines|where{$_.OperatingSystem -notlike "*Server*"}|select Name, OperatingSystem, Server, LastLogonDate, Responds, IPv4address, OU

#>>Set a count so we can view status of our script<<#
$count = 0

#>>Create our loop to get additional required details for our report<<#
FOREACH($WorkStation in $WorkStationList)
{
	$count++ #>>Add one to the count<<#
	#>>Write our status bar<<#
	Write-Progress -Activity "Gathering additional Server Details" -Status "$($count / $WorkStationList.Count * 100)% complete ($($count) of $($WorkStationList.count))" -CurrentOperation "processing Server '$($WorkStation.Name)'" -PercentComplete $($count / $WorkStationList.Count * 100)
	$WorkStation.Server = "False" #>>Set Server Field to False<<#
	#>>Get network info<<#
	$network = Test-Connection -ComputerName $WorkStation.name -Count 1 -ErrorAction SilentlyContinue
		##>>Check and write if good connection<<##
		IF($network.IPV4Address -eq $null){$WorkStation.Responds = "Disonnected"}Else{$WorkStation.Responds = "Responds"
			$WorkStation.IPv4Address = $network.IPV4Address}
		##>>Discard Network info<<##
		$network = $null 
}
#>>Export our WorkStation Report with timestamp<<##
$WorkStationlist|export-csv C:\belltech\$dateforfile-WorkStationReport.csv

