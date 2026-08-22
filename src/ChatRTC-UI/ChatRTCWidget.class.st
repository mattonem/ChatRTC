Class {
	#name : 'ChatRTCWidget',
	#superclass : 'WCComponent',
	#traits : 'InstanceComponentHolder',
	#classTraits : 'InstanceComponentHolder classTrait',
	#pools : [
		'RTCGlobals'
	],
	#category : 'ChatRTC-UI',
	#package : 'ChatRTC-UI'
}

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
							(RTCSignalingHubWidget new)
						named: #main
						on: html.
					html div
						id: #startNewConversation;
						hidden: true;
						class: 'btn btn-pimary';
						with: 'Start new conversation'. ] ]
]

{ #category : 'rendering' }
ChatRTCWidget >> start [

	self initializeComponentHolder.
	super start.
	(self getElementById: #startNewConversation)
		addEventListener: #click
		block: [console log: ((self componentNamed: #main) verifiedContacts) ]
]
