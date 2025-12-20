Class {
	#name : 'SignalingContact',
	#superclass : 'Object',
	#instVars : [
		'announcer',
		'pubRSAKey',
		'originAddress',
		'originRSAKey',
		'address',
		'open'
	],
	#pools : [
		'PjDomGlobals',
		'PjUniversalGlobals',
		'RTCGlobals'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'accessing' }
SignalingContact >> address [

	^ address
]

{ #category : 'accessing' }
SignalingContact >> address: anObject [

	address := anObject
]

{ #category : 'as yet unclassified' }
SignalingContact >> announcer [

	^ announcer
]

{ #category : 'as yet unclassified' }
SignalingContact >> arrayBufferToBase64: buffer [

	<javascript: 'let binary = '''';
  const bytes = new Uint8Array(buffer);
  const len = bytes.byteLength;
  for (let i = 0; i < len; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return window.btoa(binary);'>
	self error: 'should not be used'
]

{ #category : 'as yet unclassified' }
SignalingContact >> close [

	open := false.
	announcer announce: (SignalingStatus new status: #close)
]

{ #category : 'as yet unclassified' }
SignalingContact >> encodeAESnRSA: aJsonObject then: aBlock [

	(window crypto subtle
		 generateKey: {
				 (#name -> 'AES-GCM').
				 (#length -> 256) } asJsObject
		 extractable: true
		 purpose: { 'encrypt'. 'decrypt' } asJsObject) then: [ :key |
		| iv data |
		iv := window crypto getRandomValues: (self uint8Array: 12).
		data := TextEncoder new encode: (JSON stringify: aJsonObject).
		(window crypto subtle
			 encrypt: {
					 (#name -> 'AES-GCM').
					 (#iv -> iv) } asJsObject
			 key: key
			 data: data) then: [ :ciphertextBuffer |
			(window crypto subtle
				 wrapKey: 'raw'
				 aesKey: key
				 rsaKey: pubRSAKey
				 options: { (#name -> 'RSA-OAEP') } asJsObject) then: [
				:encryptedKey |
				aBlock
					value: (self arrayBufferToBase64: ciphertextBuffer)
					value: (self arrayBufferToBase64: encryptedKey)
					value: (self arrayBufferToBase64: iv) ] ] ]
]

{ #category : 'as yet unclassified' }
SignalingContact >> encodeRSA: encoded then: aBlock [

	(window crypto subtle
		 encrypt: { (#name -> 'RSA-OAEP') } asJsObject
		 key: pubRSAKey
		 encoded: encoded) then: [ :cipherBin |
		aBlock value: (self arrayBufferToBase64: cipherBin) ]
]

{ #category : 'as yet unclassified' }
SignalingContact >> handleAnswer: anAnswerMessage [

	announcer announce: (SignalingAnswerReceived new
			 answer: anAnswerMessage;
			 yourself)
]

{ #category : 'as yet unclassified' }
SignalingContact >> handleCandidate: anCandidateMessage [
	announcer announce: (SignalingCandidateReceived new
			 candidate: anCandidateMessage;
			 yourself)
]

{ #category : 'as yet unclassified' }
SignalingContact >> handleOffer: anOfferMessage [

	open ifTrue: [
		announcer announce: (SignalingOfferReceived new
				 offer: anOfferMessage;
				 yourself) ]
]

{ #category : 'as yet unclassified' }
SignalingContact >> initialize [

	announcer := Announcer new.
	open := false.
]

{ #category : 'as yet unclassified' }
SignalingContact >> isOpen [

	^ open
]

{ #category : 'accessing' }
SignalingContact >> isVerified [

	^ pubRSAKey isNotNil
]

{ #category : 'as yet unclassified' }
SignalingContact >> open [

	open := true.
	announcer announce: (SignalingStatus new status: #open)
]

{ #category : 'accessing' }
SignalingContact >> originAddress [

	^ originAddress
]

{ #category : 'accessing' }
SignalingContact >> originAddress: anObject [

	originAddress := anObject
]

{ #category : 'accessing' }
SignalingContact >> originRSAKey: anObject [

	originRSAKey := anObject
]

{ #category : 'as yet unclassified' }
SignalingContact >> ping [

	pubRSAKey
		ifNil: [
			(window crypto subtle exportKey: 'jwk' keys: originRSAKey) then: [
				:exportedKey |
				| anObject |
				exportedKey at: #type put: #ping.
				anObject := {
					            (#data -> exportedKey).
					            (#cyphered -> false) } asJsObject.
				self postMessage: anObject ] ]
		ifNotNil: [
			(window crypto subtle exportKey: 'jwk' keys: originRSAKey) then: [
				:exportedKey |
				exportedKey at: #type put: #ping.
				self
					encodeAESnRSA: exportedKey asJsObject
					then: [ :encryptedData :encryptedKey :iv |
						self postMessage: {
								(#data -> encryptedData).
								(#cyphered -> true).
								(#key -> encryptedKey).
								(#iv -> iv) } asJsObject ] ] ]
]

{ #category : 'as yet unclassified' }
SignalingContact >> postCopy [

	super postCopy.
	announcer := Announcer new
]

{ #category : 'as yet unclassified' }
SignalingContact >> postMessage: anObject [
	self subclassResponsibility 
]

{ #category : 'accessing' }
SignalingContact >> pubRSAKey [

	^ pubRSAKey
]

{ #category : 'accessing' }
SignalingContact >> pubRSAKey: anObject [

	pubRSAKey := anObject.
	self open.
	announcer announce: SignalingContactIsSecured new
]

{ #category : 'accessing' }
SignalingContact >> send: aMessage [

	self
		encodeAESnRSA: aMessage
		then: [ :encryptedData :encryptedKey :iv |
			self postMessage: {
					(#data -> encryptedData).
					(#cyphered -> true).
					(#key -> encryptedKey).
					(#iv -> iv) } asJsObject ]
]

{ #category : 'as yet unclassified' }
SignalingContact >> uint8Array: aNumber [
	<javascript: 'return new Uint8Array(aNumber)'>
]
