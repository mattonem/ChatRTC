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
RTCSignalingClientWidget >> close [

	signalingClient close
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
	"// --- IMPORT PRIVATE KEY (As before) ---
      const privateKey = await window.crypto.subtle.importKey(
        ""jwk"",
        fullJwk,
        { name: ""RSA-OAEP"", hash: ""SHA-256"" },
        true,
        [""decrypt""] 
      );

      // --- REGENERATE PUBLIC KEY ---
      // A public key is just the 'kty', 'n', and 'e' fields from the private key.
      const publicJwk = {
        kty: fullJwk.kty, // Key Type (RSA)
        n:   fullJwk.n,   // Modulus
        e:   fullJwk.e,   // Exponent
        alg: fullJwk.alg, // Algorithm
        ext: true         // Extractable
      };

      // Import this subset as the Public Key
      const publicKey = await window.crypto.subtle.importKey(
        ""jwk"",
        publicJwk,
        { name: ""RSA-OAEP"", hash: ""SHA-256"" },
        true,
        [""encrypt""] // Public keys are used for Encryption (or verification)
      );

      console.log(""Private Key restored:"", privateKey);
      console.log(""Public Key regenerated:"", publicKey);
      alert(""Both keys restored successfully!"");"

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
				with: [ html text: 'Chat client' ].
			html div
				class: 'card-body';
				with: [
					html div with: [
							html span
								class: 'badge text-bg-secondary';
								id: #status;
								with: 'closed' ].
					html div with: [
						html label
							class: 'form-label';
							for: 'address';
							with: 'Address'.
						html textInput disabled id: #address ].
					html div with: [
						html textInput
							class: 'form-label';
							id: #addressToCall.
						html button
							class: 'btn btn-primary';
							id: #addContact;
							with: 'Add contact' ].
					html div
						hidden: true;
						with: [
							html button
								class: 'btn btn-primary';
								id: #download;
								with: 'Download' ].
					html div id: #contacts.
					html div with: [
						html button
							class: 'btn btn-primary';
							id: #open;
							with: 'Open'.
						html button
							class: 'btn btn-secondary';
							hidden: true;
							id: #close;
							with: 'Close' ] ] ]
]

{ #category : 'rendering' }
RTCSignalingClientWidget >> signalingClient: aClient [
	signalingClient := aClient	
]

{ #category : 'rendering' }
RTCSignalingClientWidget >> start [

	super start.
	signalingClient generateNewKeys.
	(self getElementById: #download)
		addEventListener: #click
		block: [ self download ].
	(self getElementById: #addContact)
		addEventListener: #click
		block: [ self addNewContact ].
	(self getElementById: #open)
		addEventListener: #click
		block: [ signalingClient open ].
	(self getElementById: #close)
		addEventListener: #click
		block: [ self close ].
	signalingClient announcer
		when: SignalingAddressUpdated
		do: [ :e | (self getElementById: #address) value: e address ]
		for: self.
	signalingClient announcer
		when: SignalingStatus
		do: [ :event |
			event status = #open ifTrue: [
				(self getElementById: #status) className: 'badge text-bg-success' ].
			(self getElementById: #open) hidden: true.
			(self getElementById: #close) hidden: false.
			event status = #closed ifTrue: [
				(self getElementById: #status) className:
					'badge text-bg-secondary'.
				(self getElementById: #open) hidden: false.
				(self getElementById: #close) hidden: true ].
			(self getElementById: #status) innerText: event status ]
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
