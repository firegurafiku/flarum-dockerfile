<?php return array (
  'debug' => false,
  'database' => 
  array (
    'driver'    => 'mysql',
    'host'      => '$flarumDbHost',
    'database'  => '$flarumDbName',
    'username'  => '$flarumDbUser',
    'password'  => '$flarumDbPass',
    'prefix'    => '$flarumDbPrefix',
    'charset'   => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'strict'    => false,
  ),
  'url' => 'http://$flarumHostname',
  'paths' => 
  array (
    'api' => 'api',
    'admin' => 'admin',
  ),
);
