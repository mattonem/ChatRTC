Class {
	#name : 'ChatRTCWidget',
	#superclass : 'WCComponent',
	#traits : 'InstanceComponentHolder',
	#classTraits : 'InstanceComponentHolder classTrait',
	#pools : [
		'RTCGlobals'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'rendering' }
ChatRTCWidget >> newLocalClient [

	^ LocalSignalingClient new
]

{ #category : 'rendering' }
ChatRTCWidget >> newPubNubClient [

	^ PubNubSignalingClient new
		  pubKey: 'pub-c-570bf5e1-2662-46c9-812b-99d37b53c6bb';
		  subKey: 'sub-c-c9966e74-3e54-4580-af77-af4f815a104c';
		  yourself
]

{ #category : 'rendering' }
ChatRTCWidget >> renderHtmlOn: html [

	html div
		class: 'container mt-5';
		with: [
			html div
				class: 'row justify-content-center';
				with: [
					self
						addComponent:
							(RTCSignalingHubWidget new signalingClient:
									 self newPubNubClient)
						named: #main
						on: html.
					html div
						id: #startNewConversation;
						class: 'btn btn-pimary';
						with: 'Start new conversation' ] ]
]

{ #category : 'rendering' }
ChatRTCWidget >> start [

	self initializeComponentHolder.
	super start.
	(self getElementById: #startNewConversation)
		addEventListener: #click
		block: [console log: ((self componentNamed: #main) verifiedContacts) ]
]
