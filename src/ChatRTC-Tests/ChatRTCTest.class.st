"
A ChatRTCTest is a test class for testing the behavior of ChatRTC
"
Class {
	#name : 'ChatRTCTest',
	#superclass : 'PjWebAppTestCase',
	#traits : 'PjTAppRunsInJS',
	#classTraits : 'PjTAppRunsInJS classTrait',
	#category : 'ChatRTC-Tests-Core',
	#package : 'ChatRTC-Tests',
	#tag : 'Core'
}

{ #category : 'suite parameters' }
ChatRTCTest class >> appClass [
 
	^ ChatRTC 
]

{ #category : 'tests' }
ChatRTCTest >> testTest [

	| firstClient secondClient firstAddress secondAddress |
	self waitUntil: [ document readyState = 'complete' ].
	self assert: [ (document getElementById: #clients) isNotNil ].
	self assert: [ (document getElementById: #clients) children size = 0 ].
	(document getElementById: #createLocalClient) click.
	self waitUntil: [
		(document getElementById: #clients) children size ~= 0 ].
	self assert: [ (document getElementById: #clients) children size = 1 ].
	self waitUntil: [
		((document getElementById: #clients) children first querySelector:
			 '#address') value isNotEmpty ].
	self assert: [
		((document getElementById: #clients) children first querySelector:
			 '#address') value isNotEmpty ].
	firstClient := (document getElementById: #clients) children first.
	firstAddress := (firstClient querySelector: '#address') value.
	(document getElementById: #createLocalClient) click.
	self waitUntil: [
		(document getElementById: #clients) children size = 2 ].
	self waitUntil: [
		((document getElementById: #clients) children last querySelector:
			 '#address') value isNotEmpty ].
	self assert: [
		((document getElementById: #clients) children last querySelector:
			 '#address') value ~= (firstClient querySelector: '#address') value ].
	secondClient := (document getElementById: #clients) children last.
	secondAddress := (secondClient querySelector: '#address') value.

	self waitUntil: [ (secondClient querySelector: '#status') checked ].


	(firstClient querySelector: '#addressToCall') value: secondAddress.
	(firstClient querySelector: '#addContact') click.
	self waitUntil: [
		(firstClient querySelector: '#contacts') children size = 1 ].

	self waitUntil: [
		(firstClient querySelector: '#localStatusSecured') hidden = false ].
	self waitUntil: [
		(secondClient querySelector: '#contacts') children size = 1 ].


	self waitUntil: [
		(firstClient querySelector: '#localStatusSecured') hidden = false ]
]

{ #category : 'accessing' }
ChatRTCTest >> waitTimeoutDuration [

	^ 5 seconds
]
