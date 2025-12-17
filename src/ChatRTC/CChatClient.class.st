Class {
	#name : 'CChatClient',
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
CChatClient >> ab2str: something [

	<javascript: 'return String.fromCharCode.apply(null, new Uint8Array(something));'>
	^ self error: 'should not be used'
]

{ #category : 'rendering' }
CChatClient >> addContact: add pubRSAKey: key [

	contacts at: add ifPresent: [ ^ self ].
	self
		addComponent: (contacts at: add put: (CChatContact new
					  signalingContact: (PubNubSignalingContact new
							   pubKey: signalingClient pubKey;
							   subKey: signalingClient subKey;
							   originAddress: address;
							   originRSAKey: keys publicKey;
							   pubRSAKey: key;
							   yourself);
					  addressToCall: add;
					  yourself))
		in: (self getElementById: #contacts)
]

{ #category : 'rendering' }
CChatClient >> addContact: add pubRSAKey: key secured: aBoolean [

	contacts at: add ifPresent: [ :contact |
		contact pubRSAKey: key.
		^ self ].
	self
		addComponent: (contacts at: add put: (CChatContact new
					  signalingContact: (PubNubSignalingContact new
							   pubKey: signalingClient pubKey;
							   subKey: signalingClient subKey;
							   originAddress: address;
							   originRSAKey: keys publicKey;
							   pubRSAKey: key;
							   yourself);
					  addressToCall: add;
					  yourself))
		in: (self getElementById: #contacts)
]

{ #category : 'rendering' }
CChatClient >> addNewContact [

	| addressToCall |
	addressToCall := (self getElementById: #addressToCall) value
		                 ifEmpty: [ ^ self ].
	contacts at: addressToCall ifPresent: [ ^ self ].
	self
		addComponent: (contacts at: addressToCall put: (CChatContact new
					  signalingContact: (PubNubSignalingContact new
							   pubKey: signalingClient pubKey;
							   subKey: signalingClient subKey;
							   originAddress: address;
							   originRSAKey: keys publicKey;
							   yourself);
					  addressToCall: addressToCall;
					  yourself))
		in: (self getElementById: #contacts)
]

{ #category : 'rendering' }
CChatClient >> close [

	signalingClient close
]

{ #category : 'rendering' }
CChatClient >> download [

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
CChatClient >> fromJson: jsonFile [
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
CChatClient >> generateNewKeys [

	| promKeys |
	promKeys := crypto subtle
		            generateKey: {
				            (#name -> 'RSA-OAEP').
				            (#modulusLength -> 4096).
				            (#publicExponent -> self publicExponent).
				            (#hash -> 'SHA-256') } asJsObject
		            extractable: true
		            usage: { #unwrapKey. #wrapKey } asJsObject.
	promKeys then: [ :genKeys |
		| promExpKey |
		keys := genKeys.
		signalingClient privateRSAKey: keys privateKey.
		promExpKey := crypto subtle exportKey: 'spki' key: keys publicKey.
		self updateAddress ]
]

{ #category : 'rendering' }
CChatClient >> initialize [

	super initialize.
	contacts := Dictionary new
]

{ #category : 'rendering' }
CChatClient >> open [

	signalingClient openOn: address
]

{ #category : 'rendering' }
CChatClient >> publicExponent [

	<javascript: 'return new Uint8Array([1, 0, 1]);'>
	^ self error: 'should not be used'
	
]

{ #category : 'rendering' }
CChatClient >> renderHtmlOn: html [

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
CChatClient >> signalMessage: aMessage [

	console log: aMessage
]

{ #category : 'rendering' }
CChatClient >> signalingClient: aClient [
	signalingClient := aClient	
]

{ #category : 'rendering' }
CChatClient >> start [

	super start.
	keys ifNil: [ self generateNewKeys ].
	(self getElementById: #download)
		addEventListener: #click
		block: [ self download ].
	(self getElementById: #addContact)
		addEventListener: #click
		block: [ self addNewContact ].
	(self getElementById: #open)
		addEventListener: #click
		block: [ self open ].
	(self getElementById: #close)
		addEventListener: #click
		block: [ self close ].
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
		when: SignalingUnsercuredPing
		do: [ :m |
			self addContact: m address pubRSAKey: m pubRSAKey secured: false ]
		for: self.
	signalingClient announcer
		when: SignalingSercuredPing
		do: [ :m |
			self addContact: m address pubRSAKey: m pubRSAKey secured: true ]
		for: self
]

{ #category : 'rendering' }
CChatClient >> store [

	^ {  }
		  asJsObject
]

{ #category : 'rendering' }
CChatClient >> str2ab: string [

	<javascript: 'const buf = new ArrayBuffer(str.length);
  const bufView = new Uint8Array(buf);
  for (let i = 0, strLen = str.length; i < strLen; i++) {
    bufView[i] = str.charCodeAt(i);
  }
  return buf;'>
	^ self error: 'should not be used'
]

{ #category : 'rendering' }
CChatClient >> toHex: something [

	<javascript:
	'const hashArray = Array.from(new Uint8Array(something)); // convert buffer to byte array
    const hashHex = hashArray
    .map((b) => b.toString(16).padStart(2, "0"))
    .join(""); // convert bytes to hex string
  return hashHex;'>
	^ self error: 'should not be used'
]

{ #category : 'rendering' }
CChatClient >> updateAddress [

	| promExpKey |
	promExpKey := crypto subtle exportKey: 'spki' key: keys publicKey.
	promExpKey then: [ :exported |
		| hashBufferProm |
		hashBufferProm := crypto subtle digest: 'SHA-256' key: exported.
		hashBufferProm then: [ :hashBuffer |
			address := self toHex: hashBuffer.
			(self getElementById: #address) value: address ] ]
]
