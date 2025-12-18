Class {
	#name : 'ChatRTC',
	#superclass : 'PjFileBasedWebApp',
	#traits : 'StaticComponentHolder',
	#classTraits : 'StaticComponentHolder classTrait',
	#instVars : [
		'getClient',
		'connexion',
		'dataChannel',
		'uuid',
		'pubKey',
		'subKey',
		'channelName'
	],
	#pools : [
		'RTCGlobals'
	],
	#classInstVars : [
		'staticComponents'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'accessing' }
ChatRTC class >> appClasses [

	<pharoJsSkip>
	^ super appClasses , { RTCSignalingHubWidget. PubNubSignalingClient  }
]

{ #category : 'accessing' }
ChatRTC class >> bridgeClass [
	<pharoJsSkip>
	^ PjBridge
]

{ #category : 'accessing' }
ChatRTC class >> bridgeClientClass [
	<pharoJsSkip>
	
	^ PjZnHostedBrowserBridgeClient
]

{ #category : 'accessing' }
ChatRTC class >> exporterClass [

	<pharoJsSkip>
	^ PjFileExporterWithIndexHtml
]

{ #category : 'accessing' }
ChatRTC class >> generateHtmlUsing: html [

	<pharoJsSkip>
	html div
		class: 'container mt-5';
		with: [
			html div
				class: 'row justify-content-center';
				with: [
					self
						addComponent: (RTCSignalingHubWidget new signalingClient:
									 (PubNubSignalingClient new
										  pubKey: 'pub-c-570bf5e1-2662-46c9-812b-99d37b53c6bb';
										  subKey: 'sub-c-c9966e74-3e54-4580-af77-af4f815a104c';
										  yourself))
						named: #main
						on: html ] ]
]

{ #category : 'accessing' }
ChatRTC class >> initialize [ 
	<pharoJsSkip>
	super initialize.
]

{ #category : 'accessing' }
ChatRTC class >> staticComponentsSerialized [

	<jsLiteralGenerator>
	^ self _staticComponents asPhxJsonString
]

{ #category : 'accessing' }
ChatRTC class >> updateHtmlRoot: root [

	<pharoJsSkip>
	root language: 'en'.
	root stylesheet url:
		'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css'.
	root stylesheet url:
		'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css'.
		
]

{ #category : 'initialize-release' }
ChatRTC >> start [

	self initializeComponentHolder.
	super start.

	(document getElementById: #connect)
		addEventListener: #click
		do: [ self connectSignalingServer ].
	(document getElementById: #connectRTC)
		addEventListener: #click
		do: [ self connectRTC ].

	(document getElementById: #send)
		addEventListener: #click
		do: [ self sendMessage ]
]
