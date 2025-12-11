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
	#category : 'ChatRTC-Core',
	#package : 'ChatRTC',
	#tag : 'Core'
}

{ #category : 'accessing' }
ChatRTC class >> appClasses [
	^ super appClasses 
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
					html div
						class: 'col-md-6';
						with: [
							html heading
								level: 1;
								class: 'text-center mb-4';
								with: [ html text: 'Chat' ].
							html div
								class: 'card';
								with: [
									html div
										class: 'card-header';
										with: [ html text: 'SignalingServer connexion -- PubNub' ].
									html div
										class: 'card-body';
										with: [
											html div with: [
													html label
														class: 'form-label';
														for: 'subKey';
														with: 'Sub key'.
													html textInput
														class: 'form-control';
														id: 'subKey';
														with: 'sub-c-c9966e74-3e54-4580-af77-af4f815a104c' ].
											html div with: [
												html label
													class: 'form-label';
													for: 'pubKey';
													with: 'Pub key'.
												html textInput
													class: 'form-control';
													id: 'pubKey';
													with: 'pub-c-570bf5e1-2662-46c9-812b-99d37b53c6bb' ].
											html div with: [
												html label
													class: 'form-label';
													for: 'channelName';
													with: 'Channel name'.
												html textInput
													class: 'form-control';
													id: 'channelName' ].

											html button
												id: #connect;
												class: 'btn btn-primary';
												with: 'Connect to signaling server'.
											html button
												id: #connectRTC;
												class: 'btn btn-primary';
												with: 'Connect RTC' ] ].
							html div
								class: 'card';
								with: [
									html div
										class: 'card-header';
										with: [ html text: 'Conversation' ].
									html div
										class: 'card-body';
										with: [
											html div with: [
													html textArea
														class: 'form-control';
														disabled;
														id: 'conv' ].
											html div with: [
												html textInput
													class: 'form-control';
													id: 'message' ].
											html button
												id: 'send';
												with: 'Send' ] ] ] ] ]
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

{ #category : 'as yet unclassified' }
ChatRTC >> addMessage: message fromUser: user [

	| conv |
	conv := document getElementById: #conv.

	conv value:
		conv value , Character cr asString , user , ': ' , message.
	conv scrollTop: conv scrollHeight
]

{ #category : 'initialize-release' }
ChatRTC >> connectRTC [

	self createRTCA.
	connexion
		createOffer: [ :description |
			connexion
				setLocalDescription: description
				onSuccess: [ self signalSend: description ]
				onFailure: [ console log: 'Failed to create offer' ] ]
		ifFails: [ console log: 'Failed to create offer' ]
]

{ #category : 'initialize-release' }
ChatRTC >> connectSignalingServer [

	| channelInput tt |
	channelInput := document getElementById: #channelName.
	channelInput value
		ifEmpty: [
			uuid := WCUUIDGeneratorWrapper next.
			console log: 'i''m ' , uuid.

			channelName := WCUUIDGeneratorWrapper next.
			channelInput value: channelName ]
		ifNotEmpty: [ :val |
			uuid := WCUUIDGeneratorWrapper next.
			console log: 'i''m ' , uuid.

			channelName := val ].
	subKey := (document getElementById: #subKey) value.
	pubKey := (document getElementById: #pubKey) value.
	getClient := XMLHttpRequest new.
	getClient onload: [ :aClient |
		| resp messages |
		resp := JSON parse: aClient currentTarget responseText.
		tt := resp t t.
		messages := resp m.
		messages do: [ :aMessage | self signalMessage: aMessage ].
		getClient
			open: 'GET'
			url:
				'https://ps.pndsn.com/v2/subscribe/' , subKey , '/' , channelName
				, '/0?tt=' , tt , '&uuid=' , uuid.
		getClient send ].
	getClient
		open: 'GET'
		url:
			'https://ps.pndsn.com/v2/subscribe/' , subKey , '/' , channelName
			, '/0?tt=0&uuid=' , uuid.
	getClient send
]

{ #category : 'initialize-release' }
ChatRTC >> createRTCA [

	connexion := RTCPeerConnection new: { (#iceServers
		              ->
		              { { (#urls -> 'stun:stun.l.google.com:19302') }
			              asDictionary }) } asDictionary asJsObject.
	connexion ondatachannel: [ :event |
		dataChannel := event channel.
		self setupDataChannel: dataChannel ].

	dataChannel := connexion createDataChannel: 'chat'.

	self setupDataChannel: dataChannel.
	connexion onicecandidate: [ :e |
		e candidate ifNotNil: [ self sendCandidate: e candidate ] ].
	connexion onconnectionstatechange: [ :ev |
		(document getElementById: #connectRTC)
			disabled: true;
			innerHTML: connexion connectionState ]
]

{ #category : 'initialize-release' }
ChatRTC >> createRTCB [

	connexion := RTCPeerConnection new: { (#iceServers
		              ->
		              { { (#urls -> 'stun:stun.l.google.com:19302') }
			              asDictionary }) } asDictionary asJsObject.
	connexion ondatachannel: [ :event |
		dataChannel := event channel.
		self setupDataChannel: dataChannel ].

	connexion onicecandidate: [ :e |
		e candidate ifNotNil: [ self sendCandidate: e candidate ] ].
	connexion onconnectionstatechange: [ :ev |
		(document getElementById: #connectRTC)
			disabled: true;
			innerHTML: connexion connectionState ]
]

{ #category : 'as yet unclassified' }
ChatRTC >> handleAnswer: answer [

	connexion setRemoteDescription: answer.
	console log: connexion 
]

{ #category : 'as yet unclassified' }
ChatRTC >> handleOffer: offer [

	self createRTCB.
	
	connexion
		setRemoteDescription: offer
		do: [
			console log: 'remote description set'.

			connexion
				createAnswer: [ :description |
					connexion
						setLocalDescription: description
						onSuccess: [ self signalSend: description ]
						onFailure: [ :e | console log: e ] ]
				onFailure: [ :e | console log: e ] ]
		onfailure: [ :e | console log: e ]
]

{ #category : 'initialize-release' }
ChatRTC >> sendCandidate: aCandidate [

	self signalSend: aCandidate
]

{ #category : 'as yet unclassified' }
ChatRTC >> sendMessage [

	| mess |
	mess := (document getElementById: #message) value.
	self addMessage: mess fromUser: 'I say'.
	dataChannel send: mess
]

{ #category : 'as yet unclassified' }
ChatRTC >> setupDataChannel: channel [

	channel onopen: [ console log: 'Data channel is open' ].
	channel onmessage: [ :e |
		| message user |
		message := e data.
		user := 'they say'.
		self addMessage: message fromUser: user ]
]

{ #category : 'as yet unclassified' }
ChatRTC >> signalMessage: message [

	message i ~= uuid ifTrue: [
		(message d includesKey: #type)
			ifTrue: [
				message d type = 'answer'
					ifTrue: [ self handleAnswer: message d ]
					ifFalse: [ self handleOffer: message d ] ]
			ifFalse: [ connexion addIceCandidate: message d ] ]
]

{ #category : 'initialize-release' }
ChatRTC >> signalSend: object [

	| postClient |
	postClient := XMLHttpRequest new.
	postClient
		open: 'POST'
		url:
			'https://ps.pndsn.com/publish/' , pubKey , '/' , subKey , '/0/'
			, channelName , '/0?uuid=' , uuid.
	postClient send: (JSON stringify: object)
]

{ #category : 'initialize-release' }
ChatRTC >> start [

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
