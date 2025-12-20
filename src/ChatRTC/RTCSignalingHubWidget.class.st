Class {
	#name : 'RTCSignalingHubWidget',
	#superclass : 'WCComponent',
	#traits : 'InstanceComponentHolder',
	#classTraits : 'InstanceComponentHolder classTrait',
	#instVars : [
		'signalingClient',
		'clients'
	],
	#pools : [
		'RTCGlobals'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'rendering' }
RTCSignalingHubWidget >> clients [
	^ clients
]

{ #category : 'rendering' }
RTCSignalingHubWidget >> initialize [

	super initialize.
	clients := OrderedCollection new
]

{ #category : 'rendering' }
RTCSignalingHubWidget >> readClientFromFile: file [

	| reader |
	reader := FileReader new.
	reader onload: [ :e |
		| jsonClient |
		jsonClient := JSON parse: e target result.

		self
			addComponent: (RTCSignalingClientWidget new fromJson: jsonClient)
			in: (self getElementById: #clients).
		console log: jsonClient ].
	reader readAsText: file
]

{ #category : 'rendering' }
RTCSignalingHubWidget >> renderHtmlOn: html [

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
							html button
								class: 'btn btn-primary';
								id: #newClient;
								with: 'newClient'.

							html fileInput
								hidden: true;
								id: #uploadClient.
							html div id: #clients.
						
							html button
								class: 'btn btn-primary';
								hidden: true;
								attributeAt: 'data-toggle' put: 'modal';
								attributeAt: 'data-target' put: '#clientCreationModal';
								with: 'create new client'.
							html div
								class: 'modal fade';
								id: 'clientCreationModal';
								attributeAt: 'tabindex' put: '-1';
								role: 'dialog';
								with: [
									html div
										class: 'modal-dialog';
										role: 'document';
										with: [
											html div
												class: 'modal-content';
												with: [
													html div
														class: 'modal-header';
														with: [
															html heading
																level: 5;
																class: 'modal-title';
																with: 'Create new client'.
															html button
																attributeAt: 'type' put: 'button';
																class: 'close';
																attributeAt: 'data-dismiss' put: 'modal';
																with: [ html span with: 'X' ] ] ].
											html div
												class: 'modal-body';
												with: 'body'.
											html div
												class: 'modal-footer';
												with: 'footer' ] ] ] ] ]
]

{ #category : 'rendering' }
RTCSignalingHubWidget >> signalingClient: aClient [
	signalingClient := aClient	
]

{ #category : 'rendering' }
RTCSignalingHubWidget >> start [

	self initializeComponentHolder.
	super start.



	(self getElementById: #newClient)
		addEventListener: #click
		block: [ :event | |newClient|
			self
				addComponent: (RTCSignalingClientWidget new
						 signalingClient: (newClient := signalingClient copy);
						 yourself)
				in: (self getElementById: #clients).
				clients add: newClient ].
	(self getElementById: #uploadClient)
		addEventListener: #change
		block: [ :event |
			event target files ifNotEmpty: [ :files |
				self readClientFromFile: (files at: 0) ] ]
]

{ #category : 'rendering' }
RTCSignalingHubWidget >> verifiedContacts [

	| coll |
	coll := OrderedCollection new.
	clients do: [ :aClient | coll addAll: aClient verifiedContacts ].
	^ coll
]
