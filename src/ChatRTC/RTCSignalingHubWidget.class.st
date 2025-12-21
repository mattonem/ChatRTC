Class {
	#name : 'RTCSignalingHubWidget',
	#superclass : 'WCComponent',
	#traits : 'InstanceComponentHolder',
	#classTraits : 'InstanceComponentHolder classTrait',
	#instVars : [
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


							html fileInput
								hidden: true;
								id: #uploadClient.
							html div id: #clients.

							html button
								class: 'btn btn-primary';
								attributeAt: 'data-bs-toggle' put: 'modal';
								attributeAt: 'data-bs-target' put: '#clientCreationModal';
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
																class: 'btn-close';
																attributeAt: ' data-bs-dismiss' put: 'modal' ].

													html div
														class: 'modal-body';
														with: [
															html heading
																level: 6;
																with: 'Create Local Signaling Client'.
															html paragraph with:
																'This signaling client will only work for reaching out to contacts that are in the current instance of the browser. It should be used for testing purposes -- or when used in parallel with other clients type, it allows to create a local client with the same interface as your remote clients does.'.
															html div with: [
																html button
																	class: 'btn btn-primary';
																	id: #createLocalClient;
																	attributeAt: 'data-bs-dismiss' put: 'modal';
																	with: 'Create' ].
															html break.
															html heading
																level: 6;
																with: 'Create PubNub Signaling Client'.
															html paragraph with: [
																html text: 'This signaling client uses '.
																html anchor
																	url: 'https://www.pubnub.com/';
																	with: 'PubNub'.
																html text:
																	' as a Signaling server. The prefilled credentials are the one from my personal freetrial -- they might fail anytime due to popularity. You can create your own credentials on the plateform directly.' ].
															html div with: [
																html label
																	class: 'form-label';
																	for: 'pubnubSubKey';
																	with: 'Sub key'.
																html textInput
																	class: 'form-control';
																	id: #pubnubSubKey;
																	value: 'sub-c-c9966e74-3e54-4580-af77-af4f815a104c' ].
															html div with: [
																html label
																	class: 'form-label';
																	for: 'pubnubPubKey';
																	with: 'Pub key'.
																html textInput
																	class: 'form-control';
																	id: #pubnubPubKey;
																	value: 'pub-c-570bf5e1-2662-46c9-812b-99d37b53c6bb' ].
															html div with: [
																html button
																	class: 'btn btn-primary';
																	attributeAt: 'data-bs-dismiss' put: 'modal';
																	id: #createPubNubClient;
																	with: 'Create' ] ] ] ] ] ] ] ]
]

{ #category : 'rendering' }
RTCSignalingHubWidget >> start [

	self initializeComponentHolder.
	super start.

	(self getElementById: #createPubNubClient)
		addEventListener: #click
		block: [
			| newClient |
			self
				addComponent: (RTCSignalingClientWidget new
						 signalingClient: (newClient := PubNubSignalingClient new
								               pubKey: (self getElementById: #pubnubPubKey) value;
								               subKey: (self getElementById: #pubnubSubKey) value;
								               yourself);
						 yourself)
				in: (self getElementById: #clients).
			clients add: newClient ].

	(self getElementById: #createLocalClient)
		addEventListener: #click
		block: [
			| newClient |
			self
				addComponent: (RTCSignalingClientWidget new
						 signalingClient:
							 (newClient := LocalSignalingClient new yourself);
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
