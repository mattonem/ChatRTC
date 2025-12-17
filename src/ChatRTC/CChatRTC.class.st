Class {
	#name : 'CChatRTC',
	#superclass : 'WCComponent',
	#traits : 'InstanceComponentHolder',
	#classTraits : 'InstanceComponentHolder classTrait',
	#instVars : [
		'signalingClient'
	],
	#pools : [
		'RTCGlobals'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'rendering' }
CChatRTC >> initialize [

	super initialize.
	
]

{ #category : 'rendering' }
CChatRTC >> readClientFromFile: file [

	| reader |
	reader := FileReader new.
	reader onload: [ :e |
		| jsonClient |
		jsonClient := JSON parse: e target result.

		self
			addComponent: (CChatClient new fromJson: jsonClient)
			in: (self getElementById: #clients).
		console log: jsonClient ].
	reader readAsText: file
]

{ #category : 'rendering' }
CChatRTC >> renderHtmlOn: html [

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
							html div id: #clients ] ] ]
]

{ #category : 'rendering' }
CChatRTC >> signalingClient: aClient [
	signalingClient := aClient	
]

{ #category : 'rendering' }
CChatRTC >> start [

	self initializeComponentHolder.
	super start.



	(self getElementById: #newClient)
		addEventListener: #click
		block: [ :event |
			self
				addComponent: (CChatClient new
						 signalingClient: signalingClient copy;
						 yourself)
				in: (self getElementById: #clients) ].
	(self getElementById: #uploadClient)
		addEventListener: #change
		block: [ :event |
			event target files ifNotEmpty: [ :files |
				self readClientFromFile: (files at: 0) ] ]
]
