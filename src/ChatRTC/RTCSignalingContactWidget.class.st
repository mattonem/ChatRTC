Class {
	#name : 'RTCSignalingContactWidget',
	#superclass : 'WCComponent',
	#traits : 'InstanceComponentHolder',
	#classTraits : 'InstanceComponentHolder classTrait',
	#instVars : [
		'addressToCall',
		'signalingContact'
	],
	#pools : [
		'RTCGlobals'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'accessing' }
RTCSignalingContactWidget >> addressToCall: anObject [

	addressToCall := anObject
]

{ #category : 'accessing' }
RTCSignalingContactWidget >> handleOffer: offer [

	self
		addComponent: (CChatConv new
				 signalingContact: signalingContact;
				 handleOffer: offer;
				 yourself)
		in: (self getElementById: #conversation)
]

{ #category : 'accessing' }
RTCSignalingContactWidget >> ping [

	signalingContact ping
]

{ #category : 'accessing' }
RTCSignalingContactWidget >> pubRSAKey: aKey [
	signalingContact pubRSAKey: aKey
]

{ #category : 'rendering' }
RTCSignalingContactWidget >> renderHtmlOn: html [

	html div
		class: 'card';
		with: [
			html div
				class: 'card-header';
				with: [ html text: addressToCall ].
			html div
				class: 'card-body';
				with: [
					html span
						class: 'badge text-bg-warning';
						hidden: signalingContact pubRSAKey isNotNil;
						id: 'localStatusUnsecured';
						with: 'Local status unsecured'.
					html span
						class: 'badge text-bg-success';
						hidden: signalingContact pubRSAKey isNil;
						id: 'localStatusSecured';
						with: 'Local status secured' ].
			html div with: [
				html button
					class: 'btn btn-primary';
					id: #ping;
					with: 'Ping'.
				html button
					class: 'btn btn-primary';
					id: #startChat;
					with: 'Start chatting' ].
			html div id: #conversation ]
]

{ #category : 'accessing' }
RTCSignalingContactWidget >> signalingClient: anObject [

	signalingContact := anObject
]

{ #category : 'accessing' }
RTCSignalingContactWidget >> signalingContact: anObject [

	signalingContact := anObject
]

{ #category : 'accessing' }
RTCSignalingContactWidget >> start [

	super start.
	(self getElementById: #ping)
		addEventListener: #click
		block: [ self ping ].
	signalingContact announcer
		when: SignalingContactIsSecured
		do: [
			(self getElementById: #localStatusSecured) hidden: false.
			(self getElementById: #localStatusUnsecured) hidden: true ]
		for: self.
	(self getElementById: #startChat)
		addEventListener: #click
		block: [ self startChart ].

	signalingContact announcer
		when: SignalingOfferReceived
		do: [ :offer | self handleOffer: offer offer ]
		for: self
]

{ #category : 'accessing' }
RTCSignalingContactWidget >> startChart [

	self
		addComponent: (CChatConv new
				 signalingContact: signalingContact;
				 sendOffer;
				 yourself)
		in: (self getElementById: #conversation)
]
