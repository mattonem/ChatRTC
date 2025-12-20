Class {
	#name : 'LocalSignalingClient',
	#superclass : 'SignalingClient',
	#instVars : [
		'subscription'
	],
	#pools : [
		'PjDomGlobals',
		'PjUniversalGlobals',
		'RTCGlobals'
	],
	#classInstVars : [
		'announcer'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'accessing' }
LocalSignalingClient class >> announcer [

	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : 'as yet unclassified' }
LocalSignalingClient >> close [

	self class announcer unsubscribe: self.
	subscription := nil.
	announcer announce: SignalingStatus closed.
]

{ #category : 'as yet unclassified' }
LocalSignalingClient >> isOpen [

	^ subscription isNotNil
]

{ #category : 'as yet unclassified' }
LocalSignalingClient >> newContactAddress: anotherAddress pubRSAKey: key [

	
	^ LocalSignalingContact new
		  originAddress: address;
		  address: anotherAddress;
		  originRSAKey: publicRSAKey;
		  pubRSAKey: key;
		  yourself
]

{ #category : 'as yet unclassified' }
LocalSignalingClient >> open [

	subscription := self class announcer
		                when: SignalingLocalMessage
		                do: [ :aMessage | self handleMessage: aMessage message ]
		                for: self.
	announcer announce: SignalingStatus open
]

{ #category : 'as yet unclassified' }
LocalSignalingClient >> shouldHandleMessage: aMessage [

	^ aMessage target = address
]
