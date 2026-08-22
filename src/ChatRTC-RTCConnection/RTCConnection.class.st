Class {
	#name : 'RTCConnection',
	#superclass : 'Object',
	#instVars : [
		'peerConnection',
		'dataChannel',
		'signalingContact',
		'messageBlock'
	],
	#pools : [
		'PjDomGlobals',
		'RTCGlobals'
	],
	#category : 'ChatRTC-RTCConnection',
	#package : 'ChatRTC-RTCConnection'
}

{ #category : 'instance creation' }
RTCConnection class >> for: aSignalingContact [

	^ self new signalingContact: aSignalingContact
]

{ #category : 'private' }
RTCConnection >> createPeerConnection [

	peerConnection := RTCPeerConnection new: { (#iceServers -> {
		{ (#urls -> 'stun:stun.l.google.com:19302') } asDictionary }) }
		asDictionary asJsObject.
	peerConnection onicecandidate: [ :event |
		(event at: #candidate) ifNotNil: [ :candidate |
			signalingContact send: candidate ] ].
	peerConnection ondatachannel: [ :event |
		self useDataChannel: (event at: #channel) ].
]

{ #category : 'signaling' }
RTCConnection >> handleAnswer: anAnswer [

	peerConnection setRemoteDescription: anAnswer
]

{ #category : 'signaling' }
RTCConnection >> handleCandidate: aCandidate [

	peerConnection addIceCandidate: aCandidate
]

{ #category : 'signaling' }
RTCConnection >> handleOffer: anOffer [

	self createPeerConnection.
	peerConnection
		setRemoteDescription: anOffer
		do: [
			peerConnection
				createAnswer: [ :description |
					peerConnection
						setLocalDescription: description
						onSuccess: [ signalingContact send: description ]
						onFailure: [ :e | console log: e ] ]
				onFailure: [ :e | console log: e ] ]
		onfailure: [ :e | console log: e ]
]

{ #category : 'accessing' }
RTCConnection >> onMessage: aBlock [

	messageBlock := aBlock.
	dataChannel ifNotNil: [ dataChannel onMessage: messageBlock ]
]

{ #category : 'actions' }
RTCConnection >> send: aMessage [

	dataChannel send: aMessage
]

{ #category : 'signaling' }
RTCConnection >> signalingContact: aContact [

	signalingContact := aContact.
	aContact announcer
		when: SignalingCandidateReceived
		do: [ :event | self handleCandidate: event candidate ]
		for: self.
	aContact announcer
		when: SignalingAnswerReceived
		do: [ :event | self handleAnswer: event answer ]
		for: self.
	^ self
]

{ #category : 'signaling' }
RTCConnection >> startOffer [

	self createPeerConnection.
	self useDataChannel: (peerConnection createDataChannel: 'chat').
	peerConnection
		createOffer: [ :description |
			peerConnection
				setLocalDescription: description
				onSuccess: [
					description at: #appName put: #CChatConv.
					signalingContact send: description ]
				onFailure: [ console log: 'Failed to create offer' ] ]
		ifFails: [ console log: 'Failed to create offer' ]
]

{ #category : 'private' }
RTCConnection >> useDataChannel: aChannel [

	dataChannel := RTCDataChannel on: aChannel.
	messageBlock ifNotNil: [ dataChannel onMessage: messageBlock ]
]
