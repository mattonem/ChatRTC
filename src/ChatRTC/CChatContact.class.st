Class {
	#name : 'CChatContact',
	#superclass : 'WCComponent',
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
CChatContact >> addressToCall: anObject [

	addressToCall := anObject
]

{ #category : 'accessing' }
CChatContact >> ping [

	signalingContact ping: addressToCall 
]

{ #category : 'accessing' }
CChatContact >> pubRSAKey: aKey [
	signalingContact pubRSAKey: aKey
]

{ #category : 'rendering' }
CChatContact >> renderHtmlOn: html [

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
					with: 'Ping' ] ]
]

{ #category : 'accessing' }
CChatContact >> signalingClient: anObject [

	signalingContact := anObject
]

{ #category : 'accessing' }
CChatContact >> signalingContact: anObject [

	signalingContact := anObject
]

{ #category : 'accessing' }
CChatContact >> start [

	super start.
	(self getElementById: #ping)
		addEventListener: #click
		block: [ self ping ].
	signalingContact announcer
		when: SignalingContactIsSecured
		do: [
			(self getElementById: #localStatusSecured) hidden: false.
			(self getElementById: #localStatusUnsecured) hidden: true ]
		for: self
]
