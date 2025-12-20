Class {
	#name : 'SignalingClient',
	#superclass : 'Object',
	#instVars : [
		'announcer',
		'privateRSAKey',
		'contacts',
		'address',
		'publicRSAKey'
	],
	#pools : [
		'PjDomGlobals',
		'PjUniversalGlobals',
		'RTCGlobals'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'as yet unclassified' }
SignalingClient >> addContact: anotherAddress [

	| newContact |
	contacts
		at: anotherAddress
		put:
		(newContact := self newContactAddress: anotherAddress pubRSAKey: nil).
	newContact ping.
	announcer announce: (SignalingNewContact new
			 contact: newContact;
			 yourself)
]

{ #category : 'as yet unclassified' }
SignalingClient >> addContact: anotherAddress pubRSAKey: key [

	| newContact |
	contacts at: anotherAddress ifPresent: [ :aContact |
		aContact pubRSAKey: key.
		^ self ].
	contacts
		at: anotherAddress
		put:
		(newContact := self newContactAddress: anotherAddress pubRSAKey: key).

	newContact ping.

	announcer announce: (SignalingNewContact new
			 contact: newContact;
			 yourself)
]

{ #category : 'as yet unclassified' }
SignalingClient >> announcer [

	^ announcer
]

{ #category : 'as yet unclassified' }
SignalingClient >> base64ToArrayBuffer: base64 [

	<javascript: 'const binaryString = window.atob(base64);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes.buffer;'>
	self error: 'should not be used'
]

{ #category : 'as yet unclassified' }
SignalingClient >> close [

	self subclassResponsibility 
]

{ #category : 'as yet unclassified' }
SignalingClient >> contacts [

	^ contacts
]

{ #category : 'as yet unclassified' }
SignalingClient >> decodeAESnRSAMessage: message then: aBlock [

	| encryptedKeyBuffer ivBuffer ciphertextBuffer |
	encryptedKeyBuffer := self base64ToArrayBuffer: message key.
	ivBuffer := self base64ToArrayBuffer: message iv.
	ciphertextBuffer := self base64ToArrayBuffer: message data.

	(window crypto subtle
		 unwrapKey: 'raw'
		 keyBuffer: encryptedKeyBuffer
		 privateKey: privateRSAKey
		 wrapAlgo: { (#name -> 'RSA-OAEP') } asJsObject
		 targetAlgo: { (#name -> 'AES-GCM') } asJsObject
		 extractable: true
		 purpose: { 'decrypt' }) then: [ :aesKey |
		(window crypto subtle
			 decrypt: {
					 (#name -> 'AES-GCM').
					 (#iv -> ivBuffer) } asJsObject
			 key: aesKey
			 buffer: ciphertextBuffer) then: [ :decryptedBuffer |
			| decodedString |
			decodedString := TextDecoder new decode: decryptedBuffer.
			aBlock value: (JSON parse: decodedString) ] ]
]

{ #category : 'as yet unclassified' }
SignalingClient >> generateNewKeys [

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
		privateRSAKey := genKeys privateKey.
		publicRSAKey := genKeys publicKey.

		(crypto subtle exportKey: 'spki' key: publicRSAKey) then: [
			:exported |
			| hashBufferProm |
			hashBufferProm := crypto subtle digest: 'SHA-256' key: exported.
			hashBufferProm then: [ :hashBuffer |
				address := self toHex: hashBuffer.
				announcer announce: (SignalingAddressUpdated new address: address) ] ] ]
]

{ #category : 'accessing' }
SignalingClient >> getAddressForPubKey: aKey then: aBlock [

	| promExpKey |
	promExpKey := crypto subtle exportKey: 'spki' key: aKey.
	promExpKey then: [ :exported |
		| hashBufferProm |
		hashBufferProm := crypto subtle digest: 'SHA-256' key: exported.
		hashBufferProm then: [ :hashBuffer |
			| address |
			address := self toHex: hashBuffer.
			aBlock value: address ] ]
]

{ #category : 'as yet unclassified' }
SignalingClient >> handleMessage: aMessage [

	(self shouldHandleMessage: aMessage) ifFalse: [ ^ true ].
	^ aMessage d cyphered
		  ifTrue: [
			  self decodeAESnRSAMessage: aMessage d then: [ :data |
				  (data jsHasOrInheritsProperty: #candidate)
					  ifTrue: [ (contacts at: aMessage i) handleCandidate: data ]
					  ifFalse: [
						  data type = #ping ifTrue: [
							  self importPublicKey: data then: [ :importedKey |
								  self
									  getAddressForPubKey: importedKey
									  then: [ :anotherAddress |
										  anotherAddress = aMessage i ifTrue: [
											  self addContact: anotherAddress pubRSAKey: importedKey ] ] ] ].
						  data type = #offer ifTrue: [
							  (contacts at: aMessage i) handleOffer: data ].
						  data type = #answer ifTrue: [
							  (contacts at: aMessage i) handleAnswer: data ] ] ] ]
		  ifFalse: [
			  aMessage d data type = #ping ifTrue: [
				  self importPublicKey: aMessage d data then: [ :importedKey |
					  self
						  getAddressForPubKey: importedKey
						  then: [ :anotherAddress |
							  anotherAddress = aMessage i ifTrue: [
								  self addContact: anotherAddress pubRSAKey: importedKey ] ] ] ] ]
]

{ #category : 'as yet unclassified' }
SignalingClient >> importPublicKey: jwk then: aBlock [

	(window crypto subtle
		 importKey: 'jwk'
		 key: jwk
		 options: {
				 (#name -> 'RSA-OAEP').
				 (#hash -> 'SHA-256') } asJsObject
		 extractable: true
		 usage: { #wrapKey } asJsObject) then: aBlock
]

{ #category : 'as yet unclassified' }
SignalingClient >> initialize [

	announcer := Announcer new.
	contacts := Dictionary new.
]

{ #category : 'as yet unclassified' }
SignalingClient >> isClosed [
	^ self isOpen not
]

{ #category : 'as yet unclassified' }
SignalingClient >> isOpen [

	self subclassResponsibility 
]

{ #category : 'as yet unclassified' }
SignalingClient >> newContactAddress: anotherAddress pubRSAKey: key [

	self subclassResponsibility 
]

{ #category : 'as yet unclassified' }
SignalingClient >> open [

	self subclassResponsibility 
]

{ #category : 'as yet unclassified' }
SignalingClient >> postCopy [

	super postCopy.
	announcer := Announcer new.
	contacts := Dictionary new.
]

{ #category : 'as yet unclassified' }
SignalingClient >> privateRSAKey: anObject [
	privateRSAKey := anObject
]

{ #category : 'as yet unclassified' }
SignalingClient >> publicExponent [

	<javascript: 'return new Uint8Array([1, 0, 1]);'>
	^ self error: 'should not be used'
	
]

{ #category : 'as yet unclassified' }
SignalingClient >> shouldHandleMessage: aMessage [

	^ true
]

{ #category : 'as yet unclassified' }
SignalingClient >> toHex: something [

	<javascript:
	'const hashArray = Array.from(new Uint8Array(something)); // convert buffer to byte array
    const hashHex = hashArray
    .map((b) => b.toString(16).padStart(2, "0"))
    .join(""); // convert bytes to hex string
  return hashHex;'>
	^ self error: 'should not be used'
]

{ #category : 'as yet unclassified' }
SignalingClient >> verifiedContacts [
	^ contacts values select: [ :aContact | aContact isVerified  ]
]
