# This script can be runned from scheduler (every day at 3am for example).
# This script checks for a new ROS version, compares build time of current and available version,
# and updates or notifies of ROS update availability according to $daysTimeout variable calculations. 
#

:local changelog ([/tool fetch "https://upgrade.mikrotik.com/routeros/NEWESTa7.stable" as-value output=user] -> "data");
:local changelogTime [:pick $changelog ([:find $changelog " "]+1) ([:find $changelog " "]+11)];
:local changelogVersion [:pick $changelog 0 [:find $changelog " "]];
:local installedBuildTime [:tonum [:totime [system package get [find where name="routeros"] build-time]]];
:local currentTime [:tonum [:timestamp]];
:local mtVersion [/system package get [find where name="routeros"] version]

if ($installedBuildTime != $changelogTime) do={
 :local daysDifference (($currentTime - $changelogTime) / 86400);
 :local daysTimeout 14;
 :local daysBeforeUpdate ($daysTimeout - $daysDifference);
 :if ($daysDifference >= $daysTimeout) do={
  :log warning "Updating Mikrotik ROS from $mtVersion to $changelogVersion"
  delay 10
  /system package update; check-for-updates; install;
  } else={
   :log warning "Update of Mikrotik ROS from $mtVersion to $changelogVersion will be installed in $daysBeforeUpdate days"
  }
}