Class {
	#name : 'LocalSignalingContact',
	#superclass : 'SignalingContact',
	#category : 'ChatRTC-RTCConnection',
	#package : 'ChatRTC-RTCConnection'
}

{ #category : 'as yet unclassified' }
LocalSignalingContact >> postMessage: anObject [

	LocalSignalingClient announcer announce:
		(SignalingLocalMessage new message: {
				 (#d -> anObject).
				 (#i -> originAddress).
				 (#target -> address) } asJsObject)
]
