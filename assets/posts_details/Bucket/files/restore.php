#!/usr/bin/php
<?php
require '/var/www/bucket-app/vendor/autoload.php';
date_default_timezone_set('America/New_York');
use Aws\DynamoDb\DynamoDbClient;
use Aws\DynamoDb\Exception\DynamoDbException;

$client = new Aws\Sdk([
    'profile' => 'default',
    'region'  => 'us-east-1',
    'version' => 'latest',
    'endpoint' => 'http://localhost:4566'
]);

$dynamodb = $client->createDynamoDb();
$params = [
    'TableName' => 'alerts'
];
$tableName='users';
try {
$response = $dynamodb->createTable([
	'TableName' => $tableName,
	'AttributeDefinitions' => [
		[
			'AttributeName' => 'username',
			'AttributeType' => 'S'
		],
		[
			'AttributeName' => 'password',
			'AttributeType' => 'S'
		]
	],
	'KeySchema' => [
		[
			'AttributeName' => 'username',
			'KeyType' => 'HASH'
		],
		[
			'AttributeName' => 'password',
			'KeyType' => 'RANGE'
		]
	],
	'ProvisionedThroughput' => [
             'ReadCapacityUnits'    => 5,
             'WriteCapacityUnits' => 5
        ]
]);

$response = $dynamodb->putItem(array(
    'TableName' => $tableName, 
    'Item' => array(
        'username'   => array('S' => 'Cloudadm'),
        'password'  => array('S' => 'Welcome123!')
    )
));

$response = $dynamodb->putItem(array(
    'TableName' => $tableName, 
    'Item' => array(
        'username'   => array('S' => 'Mgmt'),
        'password'  => array('S' => 'Management@#1@#')
    )
));

$response = $dynamodb->putItem(array(
    'TableName' => $tableName, 
    'Item' => array(
        'username'   => array('S' => 'Sysadm'),
        'password'  => array('S' => 'n2vM-<_K_Q:.Aa2')
    )
));}
catch(Exception $e) {
  echo 'Message: ' .$e->getMessage();
}
$result = $dynamodb->deleteTable($params);

