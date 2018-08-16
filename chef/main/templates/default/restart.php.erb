<?php

/**
 * Convert dattime string to unixtime
 * 
 * @param  string $source
 * @return int
 * @throws LogicException
 */
function toUnixtime($source) {
  $matches = array();

  if (preg_match('~^[a-z]{3}\s+([a-z]{3})\s+(\d{2})\s+(\d{2}):(\d{2}):(\d{2})(?:\.\d{6})?\s+(\d{4})$~i', $source, $matches)) {
    $months = array(
        'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4,
        'May' => 5, 'Jun' => 6, 'Jul' => 7, 'Aug' => 8,
        'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12
    );

    list($src, $month, $day, $hour, $min, $sec, $year) = $matches;

    if (!isset($months[$month])) {
      throw new LogicException(sprintf('Invalid month "%s"', $months[$month]));
    }

    $RFC3339 = sprintf('%s-%s-%02dT%s:%s:%s', $year, $months[$month], $day, $hour, $min, $sec);

    return strtotime($RFC3339);
  }

  $time = strtotime($source);

  if ($time === false) {
    throw new LogicException(sprintf('Invalid datatime format: "%s"', $source));
  }

  return $time;
}

$restart = exec('grep resuming /var/log/httpd/error_log | tail -1');
//var_dump($restart);
//Get last time apache was restarted
preg_match("/\[([^\]]*)\]/", $restart, $restarttime);
print "Last Apache Restart was " . $restarttime[1] . "\n";
$restarttime = toUnixtime(trim($restarttime[1]));
print "Apache Restart Time converted to Timestamp is " . $restarttime . "\n";
//var_dump($restarttime);

if ($restarttime) {
  //var_dump($restarttime);
  $path = "<%= node[:install][:document_root] %>/<%= node[:install][:software_name] %>/clients/<%= node[:install][:client_name] %>/Vhosts";
  $restart_now = false;
  $d = dir($path);
  
  while (false !== ($entry = $d->read())) {
    $filepath = "{$path}/{$entry}";
    // could do also other checks than just checking whether the entry is a file
    if (is_file($filepath) && filectime($filepath) > $restarttime) {
      echo $filepath . " - " . filectime($filepath) . " > " . $restarttime . "\n";
      $restart_now = true;
    }
  }
  //var_dump($latest_ctime);

  if ($restart_now) {
    print("Restarting Apache....");
    //exec('/etc/init.d/httpd restart');
    //Need code to test if fails..
    //If the above did not work with you then try this
    //exec('for i in `lsof -i :80 | grep http | awk {' print $2'}`; do kill -9 $i; done');
    //Then perform the restart:
    exec('/usr/bin/sudo /sbin/service httpd restart');
  }
}
?>