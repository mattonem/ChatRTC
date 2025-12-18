Class {
	#name : 'CChatConv',
	#superclass : 'WCComponent',
	#instVars : [
		'dataChannel',
		'connexion',
		'signalingContact'
	],
	#pools : [
		'RTCGlobals'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'rendering' }
CChatConv >> addMessage: message fromUser: user [

	| conv |
	conv := self getElementById: #conv.

	conv value:
		conv value , Character cr asString , user , ': ' , message.
	conv scrollTop: conv scrollHeight
]

{ #category : 'rendering' }
CChatConv >> handleAnswer: answer [

	connexion setRemoteDescription: answer
]

{ #category : 'rendering' }
CChatConv >> handleCandidate: aCandidate [
	(connexion at: #currentRemoteDescription) ifNotNil: [connexion addIceCandidate: aCandidate]
]

{ #category : 'rendering' }
CChatConv >> handleOffer: anOffer [

	signalingContact announcer
		when: SignalingCandidateReceived
		do: [ :aCandidate | self handleCandidate: aCandidate candidate ]
		for: self.
	connexion := RTCPeerConnection new: { (#iceServers
		              ->
		              { { (#urls -> 'stun:stun.l.google.com:19302') }
			              asDictionary }) } asDictionary asJsObject.
	connexion ondatachannel: [ :event |
		dataChannel := event channel.
		self setupDataChannel: dataChannel ].

	connexion onicecandidate: [ :e |
		(e at: #candidate) ifNotNil: [
			self sendCandidate: (e at: #candidate) ] ].
	connexion onconnectionstatechange: [ :ev |  ].

	console log: anOffer.
	connexion
		setRemoteDescription: anOffer
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

{ #category : 'rendering' }
CChatConv >> renderHtmlOn: html [

	html div
		class: 'card';
		with: [
			html div
				class: 'card-header';
				with: 'Conversation'.
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
						class: 'btn btn-primary';
						id: 'send';
						with: 'Send' ] ]
]

{ #category : 'rendering' }
CChatConv >> sendCandidate: aCandidate [
	console log: aCandidate.
	self signalSend: aCandidate
]

{ #category : 'rendering' }
CChatConv >> sendMessage [

	| mess |
	mess := (self getElementById: #message) value.
	self addMessage: mess fromUser: 'I say'.
	dataChannel send: mess.
]

{ #category : 'rendering' }
CChatConv >> sendOffer [

	signalingContact announcer
		when: SignalingCandidateReceived
		do: [ :aCandidate | self handleCandidate: aCandidate candidate ]
		for: self.
	signalingContact announcer
		when: SignalingAnswerReceived
		do: [ :anAnwser | self handleAnswer: anAnwser answer ]
		for: self.
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
		(e at: #candidate) ifNotNil: [
			self sendCandidate: (e at: #candidate) ] ].
	connexion onconnectionstatechange: [ :ev |  ].
	connexion
		createOffer: [ :description |
			connexion
				setLocalDescription: description
				onSuccess: [
					description at: #appName put: #CChatConv.

					self signalSend: description ]
				onFailure: [ console log: 'Failed to create offer' ] ]
		ifFails: [ console log: 'Failed to create offer' ]
]

{ #category : 'rendering' }
CChatConv >> setupDataChannel: channel [

	channel onopen: [ console log: 'Data channel is open' ].
	channel onmessage: [ :e |
		| message user |
		message := e data.
		user := 'they say'.
		self addMessage: message fromUser: user ]
]

{ #category : 'rendering' }
CChatConv >> signalSend: aMessage [
	signalingContact send: aMessage
]

{ #category : 'accessing' }
CChatConv >> signalingContact: anObject [

	signalingContact := anObject
]

{ #category : 'rendering' }
CChatConv >> start [

	super start.
	(self getElementById: #send)
		addEventListener: #click
		block: [ self sendMessage ].
	
]
