<?php

$dir_path = realpath(dirname(__FILE__) . '/../texts/');

$dir = opendir($dir_path);
$blacks = array('.', '..', 'gl3_nd_pov.tex', 'gl4_nd_pol.tex');
$control_time = time() - (60 * 60 * 24);

while(($filename = readdir($dir)) !== false)
{
	if(in_array($filename, $blacks))
		continue;

	$file = sprintf('%s/%s', $dir_path, $filename);
	if(filemtime($file) > $control_time)
		continue;

	exec(sprintf('perl %s/hip2tex.pl %s > %2$s_', dirname(__FILE__), $file));
	echo $filename, PHP_EOL;
}

echo 'Done!', PHP_EOL;