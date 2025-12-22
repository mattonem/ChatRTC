Class {
	#name : 'RTCSignalingClientWidget',
	#superclass : 'WCComponent',
	#traits : 'InstanceComponentHolder',
	#classTraits : 'InstanceComponentHolder classTrait',
	#instVars : [
		'keys',
		'address',
		'signalingClient',
		'contacts'
	],
	#pools : [
		'RTCGlobals'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'rendering' }
RTCSignalingClientWidget >> addContact: aContact [

	| addressToCall |
	addressToCall := aContact address.
	self
		addComponent:
			(contacts at: addressToCall put: (RTCSignalingContactWidget new
					  signalingContact: aContact;
					  addressToCall: addressToCall;
					  yourself))
		in: (self getElementById: #contacts)
]

{ #category : 'rendering' }
RTCSignalingClientWidget >> addNewContact [

	| addressToCall |
	addressToCall := (self getElementById: #addressToCall) value
		                 ifEmpty: [ ^ self ].
	self addNewContact: addressToCall
]

{ #category : 'rendering' }
RTCSignalingClientWidget >> addNewContact: anotherAddress [

	signalingClient addContact: anotherAddress
]

{ #category : 'rendering' }
RTCSignalingClientWidget >> download [

	(window crypto subtle exportKey: 'jwk' keys: keys privateKey) then: [
		:exportedKey |
		| jsonString blob url link |
		jsonString := JSON stringify: { (#keys -> { #privateKey -> exportedKey}) } asJsObject.
		blob := Blob
			        new: { jsonString }
			        with: { (#type -> 'application/json') } asJsObject.

		url := URL createObjectURL: blob.
		link := document createElement: 'a'.
		link href: url.
		link download: 'client.json'.
		document body appendChild: link.
		link click.
		document body removeChild: link.
		URL revokeObjectURL: url ]
]

{ #category : 'rendering' }
RTCSignalingClientWidget >> fromJson: jsonFile [

	| fullJwk |
	fullJwk := jsonFile keys privateKey.
	(window crypto subtle
		 importKey: 'jwk'
		 data: fullJwk
		 options: {
				 (#name -> 'RSA-OAEP').
				 (#hash -> 'SHA-256') } asJsObject
		 extractable: true
		 keyUsages: { 'decrypt'. 'encrypt' } asJsObject) then: [ :key |
		console log: key ]
]

{ #category : 'rendering' }
RTCSignalingClientWidget >> initialize [

	super initialize.
	contacts := Dictionary new
]

{ #category : 'rendering' }
RTCSignalingClientWidget >> renderHtmlOn: html [

	html div
		class: 'card';
		with: [
			html div
				class: 'card-header';
				with: [
					html div
						class: 'd-flex';
						with: [
							html paragraph
								class: 'flex-grow-1';
								with: 'Chat client'.
							html div
								class: 'form-check form-switch';
								with: [
									html checkbox
										checked: signalingClient isOpen;
										class: 'form-check-input';
										id: 'status' ] ] ].
			html div
				class: 'card-body';
				with: [
					html div
						class: 'form-group row';
						with: [
							html label
								class: 'col-sm-2 col-form-label';
								for: 'address';
								with: 'My address'.
							html div
								class: 'col-sm-10';
								with: [
									html textInput
										class: 'form-control';
										disabled;
										id: #address ] ].
					html div class: 'form-inline'; with: [
						html label
							class: 'form-label';
							for: 'address';
							with: 'Address to call'.
						html textInput
							class: 'form-control mb-2 mr-sm-2';
							id: #addressToCall.
						html button
							class: 'btn btn-primary mb-2';
							id: #addContact;
							with: 'Call' ].
					html div
						hidden: true;
						with: [
							html button
								class: 'btn btn-primary';
								id: #download;
								with: 'Download' ].
					html div id: #contacts ] ]
]

{ #category : 'rendering' }
RTCSignalingClientWidget >> signalingClient: aClient [
	signalingClient := aClient	
]

{ #category : 'rendering' }
RTCSignalingClientWidget >> start [

	self initializeComponentHolder.
	super start.
	signalingClient generateNewKeys.


	(self getElementById: #download)
		addEventListener: #click
		block: [ self download ].
	(self getElementById: #addContact)
		addEventListener: #click
		block: [ self addNewContact ].
	(self getElementById: #status)
		addEventListener: #click
		block: [ :e |
			signalingClient isOpen
				ifTrue: [ signalingClient close ]
				ifFalse: [ signalingClient open ] ].

	signalingClient announcer
		when: SignalingAddressUpdated
		do: [
			signalingClient close.
			signalingClient open ]
		for: self.
	signalingClient announcer
		when: SignalingAddressUpdated
		do: [ :e | (self getElementById: #address) value: e address ]
		for: self.
	signalingClient announcer
		when: SignalingStatus
		do: [ :event |
			(self getElementById: #status) checked: signalingClient isOpen ]
		for: self.
	signalingClient announcer
		when: SignalingNewContact
		do: [ :m | self addContact: m contact ]
		for: self
]

{ #category : 'rendering' }
RTCSignalingClientWidget >> store [

	^ {  }
		  asJsObject
]
